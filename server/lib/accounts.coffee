# Deny Account.createUser in client
accountsConfig = { forbidClientAccountCreation: true }

if RocketChat.settings.get('Account_AllowedDomainsList')
	domainWhiteList = _.map RocketChat.settings.get('Account_AllowedDomainsList').split(','), (domain) -> domain.trim()
	accountsConfig.restrictCreationByEmailDomain = (email) ->
		ret = false
		for domain in domainWhiteList
			if email.match(domain + '$')
				ret = true
				break;

		return ret

Accounts.config accountsConfig

Accounts.emailTemplates.siteName = RocketChat.settings.get 'Site_Name';
Accounts.emailTemplates.from = "#{RocketChat.settings.get 'Site_Name'} <#{RocketChat.settings.get 'From_Email'}>";

verifyEmailText = Accounts.emailTemplates.verifyEmail.text
Accounts.emailTemplates.verifyEmail.text = (user, url) ->
	url = url.replace Meteor.absoluteUrl(), Meteor.absoluteUrl() + 'login/'
	verifyEmailText user, url

resetPasswordText = Accounts.emailTemplates.resetPassword.text
Accounts.emailTemplates.resetPassword.text = (user, url) ->
	url = url.replace Meteor.absoluteUrl(), Meteor.absoluteUrl() + 'login/'
	verifyEmailText user, url

Accounts.onCreateUser (options, user) ->
	# console.log 'onCreateUser ->',JSON.stringify arguments, null, '  '
	# console.log 'options ->',JSON.stringify options, null, '  '
	# console.log 'user ->',JSON.stringify user, null, '  '

	RocketChat.callbacks.run 'beforeCreateUser', options, user

	user.status = 'offline'
	user.active = not RocketChat.settings.get 'Accounts_ManuallyApproveNewUsers'

	if not user?.name? or user.name is ''
		if options.profile?.name?
			user.name = options.profile?.name

	if user.services?
		for serviceName, service of user.services
			if not user?.name? or user.name is ''
				if service.name?
					user.name = service.name
				else if service.username?
					user.name = service.username

			if not user.emails? and service.email?
				user.emails = [
					address: service.email
					verified: true
				]

	return user

# Wrap insertUserDoc to allow executing code after Accounts.insertUserDoc is run
Accounts.insertUserDoc = _.wrap Accounts.insertUserDoc, (insertUserDoc) ->
	options = arguments[1]
	user = arguments[2]
	_id = insertUserDoc.call(Accounts, options, user)

	# when inserting first user give them admin privileges otherwise make a regular user
	org = RocketChat.models.Organizations.findOneByDomain(options.email.split('@')[1])
	users = RocketChat.models.Users.find({organizationId: org._id}).fetch()
	console.log(users.length)
	roleName = if (users && users.length > 0) then 'user' else 'admin'

	RocketChat.authz.addUsersToRoles(_id, roleName)
	RocketChat.callbacks.run 'afterCreateUser', options, user
	return _id

Accounts.validateLoginAttempt (login) ->
	login = RocketChat.callbacks.run 'beforeValidateLogin', login

	if login.allowed isnt true
		return login.allowed

	if login.user?.active isnt true
		throw new Meteor.Error 'inactive-user', TAPi18n.__ 'User_is_not_activated'
		return false

	validEmail = login.user.emails.filter (email) ->
		return email.verified is true

	if validEmail.length is 0
		throw new Meteor.Error 'no-valid-email'
		return false

	RocketChat.models.Users.updateLastLoginById login.user._id
	RocketChat.models.Mentions.removeByUserId login.user._id

	Meteor.defer ->
		RocketChat.callbacks.run 'afterValidateLogin', login

	return true

# Handle login of user via uuid > confirmation email link
Accounts.registerLoginHandler (options) ->
	if !options.uuid or !Meteor.users.findOne(uuid: options.uuid)
		return undefined
	user = Meteor.users.findOne(uuid: options.uuid)

	domain = user.emails[0].address.split('@')[1]
	org = RocketChat.models.Organizations.findOneByDomain domain

	# send welcome/invite message
	Mandrill.messages.sendTemplate
		'template_name': 'meteor-sign-up-2-confirmation'
		'template_content': [ {} ]
		'message':
			subject: 'Welcome on board!'
			from_email: 'support@teamstitch.com'
			from_name: 'Stitch'
			'global_merge_vars': [ {
				'name': 'organizationName'
				'content': org.name
			} ]
			'to': [ { 'email': user.emails[0].address } ]
			important: true

	return { userId: user._id }
