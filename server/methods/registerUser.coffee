Meteor.methods
	registerUser: (formData) ->
		orgId = null;

		if formData.orgId
			orgId = formData.orgId
		else
			orgName = RocketChat.services.capitalizeFirstLetter formData.orgName
			org = RocketChat.models.Organizations.createWithNameAndDomain orgName, formData.email.split('@')[1], 1
			orgId = org._id
			RocketChat.models.Rooms.createWithNameTypeAndOrgId 'general', 'c', orgId,	default: true

		RocketChat.models.Organizations.updateOrgUserCountById orgId, 1

		loginData =
			email: formData.email
			password: formData.pass

		userId = Accounts.createUser loginData

		firstName = RocketChat.services.capitalizeFirstLetter formData.firstName
		lastName = RocketChat.services.capitalizeFirstLetter formData.lastName

		username = firstName + '.' + lastName;

		i = 2
		while not RocketChat.checkUsernameAvailability username, orgId
			username = firstName + '.' + lastName + '.' + i;
			i++

		userData =
			degree: formData.degree
			firstName: firstName
			lastName: lastName
			username: username
			phone: formData.phone
			orgId: orgId
			uuid: uuid.new();
		RocketChat.models.Users.setUserData userId, userData

		if loginData.email
			Mandrill.messages.sendTemplate({
				"template_name": "meteor-sign-up-1-authenticate",
				"template_content": [{}],
				"message": {
					subject: 'Invitation to Stitch',
					from_email: 'support@teamstitch.com',
					from_name: 'Stitch',
					"global_merge_vars": [
						{
							"name": "confirmAccountUrl",
							"content": Meteor.absoluteUrl('verify/' + userData.uuid)
						}
					],
					"to": [{"email": loginData.email}],
					important: true
				}
			});

	emailExists: (email) ->
		user = Meteor.users.findOne('emails.address': email)
		if user
			true
		else
			false

	verifyUser: (uuid) ->
		check uuid, String
		# Check user exists
		if !uuid or !Meteor.users.findOne(uuid: uuid)
			throw new (Meteor.Error)(404, 'User does not exist')
		user = Meteor.users.findOne(uuid: uuid)
		user.emails[0].verified = true
		Meteor.users.update user._id, user

	resetUserPassword: (uuid, newPassword) ->
		check uuid, String
		# Check user exists
		if !uuid or !Meteor.users.findOne(uuid: uuid)
			throw new (Meteor.Error)(404, 'User does not exist')
		user = Meteor.users.findOne(uuid: uuid)
		Accounts.setPassword user._id, newPassword
