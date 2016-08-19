Template.listChannelsFlex.helpers
	channel: ->
		return Session.get 'channelsList'

Template.listChannelsFlex.events
	'click header': ->
		SideNav.closeFlex()

	'click .channel-link': ->
		SideNav.closeFlex()

	'click footer .create': ->
		if RocketChat.authz.hasAtLeastOnePermission( 'create-c')
			SideNav.setFlex "createChannelFlex"

	'mouseenter header': ->
		SideNav.overArrow()

	'mouseleave header': ->
		SideNav.leaveArrow()

Template.listChannelsFlex.onCreated ->
	instance = this
	instance.channelsList = new ReactiveVar []

	Meteor.call 'channelsList', (err, result) ->
		if result
			Session.set 'channelsList', result.channels

