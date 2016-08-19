Meteor.publish 'room', ->
	unless this.userId
		return this.ready()

	console.log '[publish] room ->'.green, 'arguments:', arguments

	user = RocketChat.models.Users.findOneById this.userId, fields: organizationId: 1
	RocketChat.models.Rooms.findByOrgId user.organizationId
