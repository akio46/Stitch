Meteor.publish 'subscription', ->
	unless this.userId
		return this.ready()

	console.log '[publish] subscription'.green

	user = RocketChat.models.Users.findOneById this.userId, fields: organizationId: 1
	RocketChat.models.Subscriptions.findByOrgId user.organizationId,
		fields:
			t: 1
			ts: 1
			ls: 1
			name: 1
			receiverName: 1
			rid: 1
			f: 1
			open: 1
			alert: 1
			unread: 1
			'u._id': 1
			'u.name': 1
			'u.username': 1
			organizationId: 1
