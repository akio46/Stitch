Meteor.methods
	log: ->
		console.log.apply console, arguments

Meteor.startup ->

	Push.debug = true

	#if RocketChat.settings.get('Push_enable') is true
	Push.enabled = true
	Push.allow
		send: (userId, notification) ->
			return true