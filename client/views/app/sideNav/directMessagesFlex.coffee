Template.directMessagesFlex.helpers
	error: ->
		return Template.instance().error.get()

	users: ->
		return Template.instance().usersList?.get()

Template.directMessagesFlex.events
	'autocompleteselect #who': (event, instance, doc) ->
		instance.selectedUser.set doc.username
		event.currentTarget.focus()

	'click .cancel-direct-message': (e, instance) ->
		SideNav.closeFlex()
		instance.clearForm()

	'click header': (e, instance) ->
		SideNav.closeFlex()
		instance.clearForm()

	'mouseenter header': ->
		SideNav.overArrow()

	'mouseleave header': ->
		SideNav.leaveArrow()

	'keydown input[type="text"]': (e, instance) ->
		Template.instance().error.set([])

	'click a.channel-link': (e, instance) ->
		username = $(e.target).data('username')
		instance.createDirectChannel(username)

Template.directMessagesFlex.onCreated ->
	instance = this
	instance.error = new ReactiveVar []
	instance.usersList = new ReactiveVar []

	Meteor.call 'usersList', (err, result) ->
		if result
			instance.usersList.set result.users

	instance.clearForm = ->
		instance.error.set([])

	instance.createDirectChannel = (username) ->
		err = SideNav.validate()
		if not err
			Meteor.call 'createDirectMessage', username, (err, result) ->
				if err
					return toastr.error err.reason
				SideNav.closeFlex()
				instance.clearForm()
				FlowRouter.go 'direct', { username: username }
		else
			Template.instance().error.set(err)