Meteor.publish 'userData', ->
	unless this.userId
		return this.ready()

	console.log '[publish] userData'.green

	RocketChat.models.Users.find this.userId,
		fields:
			firstName: 1
			lastName: 1
			name: 1
			username: 1
			displayName: 1
			degree: 1
			phone: 1
			status: 1
			statusDefault: 1
			statusConnection: 1
			avatarOrigin: 1
			utcOffset: 1
			language: 1
			settings: 1
			defaultRoom: 1
			organizationId: 1
			'services.github.id': 1
			'services.gitlab.id': 1

Meteor.publish 'usersData', ->
	if !@userId
		return this.ready()
	Meteor.users.find {}, fields: organizationId: 1
