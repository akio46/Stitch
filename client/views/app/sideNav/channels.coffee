Template.channels.helpers
	tRoomMembers: ->
		return t('Members_placeholder')

	isActive: ->
		return 'active' if ChatSubscription.findOne({ 'u._id': Meteor.userId(), t: { $in: ['c']}, f: { $ne: true }, open: true, rid: Session.get('openedRoom') }, { fields: { _id: 1 } })?

	rooms: ->
		query =
			name: { $ne: 'general'},
			t: { $in: ['c']},
			open: true,
			'u._id': Meteor.userId()

		if !RocketChat.settings.get 'Disable_Favorite_Rooms'
			query.f = { $ne: true }

		if Meteor.user()?.settings?.preferences?.unreadRoomsMode
			query.alert =
				$ne: true

		channels = ChatSubscription.find(query, { sort: 't': 1, 'name': 1 }).fetch()
		general = ChatSubscription.findOne {name: 'general', 'u._id': Meteor.userId()}
		channels.unshift(general)
		return channels

Template.channels.events
	'click .add-room': (e, instance) ->
		if RocketChat.authz.hasAtLeastOnePermission('create-c')
			SideNav.setFlex "createChannelFlex"
			SideNav.openFlex()
		else
			e.preventDefault()

	'click .more-channels': ->
		SideNav.setFlex "listChannelsFlex"
		SideNav.openFlex()
