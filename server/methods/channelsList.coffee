Meteor.methods
	channelsList: ->
		orgId = Meteor.user().organizationId;

		query =
			t: 'c'
			organizationId: orgId
			name:
				$ne: 'general'
		channels = RocketChat.models.Rooms.find(query, { sort: { msgs:-1 } }).fetch()
		general = RocketChat.models.Rooms.findOne {name: 'general', organizationId: orgId}
		channels.unshift(general)

		return { channels: channels }
