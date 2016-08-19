Meteor.methods
	# Add organization
	'editOrgName': (orgId, name) ->
		org = RocketChat.models.Organizations.editOrgName(orgId, name)
		return org

	'addDomainToOrg': (orgId, domain) ->
		org = RocketChat.models.Organizations.addDomainToOrg(orgId, domain)
		return org

	'removeDomainFromOrg': (orgId, domain) ->
		org = RocketChat.models.Organizations.removeDomainFromOrg(orgId, domain)
		return org

	'findOrgById': (orgId) ->
		domains = RocketChat.models.Organizations.findOneById(orgId)
		return domains

	'findOrgIdByDomain': (domain) ->
		org = RocketChat.models.Organizations.findOneByDomain domain
		if org
			return org._id
		else
			return null

	'findOrgNameById': (id) ->
		org = RocketChat.models.Organizations.findOneById id
		if org
			return org.name
		else
			return null

	'findOrgUserCountById': (id) ->
		org = RocketChat.models.Organizations.findOneById id
		if org
			return org.userCount
		else
			return null

	'updateOrgUserCountById': (id) ->
		console.log('update Org user count')

		if not Meteor.userId()
			throw new Meteor.Error('invalid-user', "[methods] toogleFavorite -> Invalid user")

		RocketChat.models.Organizations.updateOrgUserCountById id , 1
