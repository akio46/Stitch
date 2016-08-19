Template.message.helpers
	actions: ->
		return RocketChat.MessageAction.getButtons(this)

	own: ->
		return 'own' if this.u?._id is Meteor.userId()

	chatops: ->
		return 'chatops-message' if this.u?.username is RocketChat.settings.get('Chatops_Username')

	time: ->
		return moment(this.ts).format('hh:mm a')

	date: ->
		return moment(this.ts).format('LL')

	isTemp: ->
		if @temp is true
			return 'temp'
		return

	isSequential: ->
		query =
			rid: this.rid
			ts: $lt: this.ts
			t: { '$ne': 't' }

		previous = ChatMessage.findOne query, { sort: ts: -1, limit: 1 }

		if (previous?.u._id isnt this.u._id) or (moment(this.ts).diff(previous.ts) > 120000)
			return ''
		return 'sequential'

	messageReads: ->
		query =
			'u._id':
				$ne: Meteor.userId()
			rid: this.rid

		subscriptions = ChatSubscription.find(query).fetch()
		readBy = []

		for subscription in subscriptions
			if this.ts < subscription.ls
				if (subscription.t is 'd') and (this.u._id is Meteor.userId())
					return 'Seen'
				else
					pattern = /\B@[.a-z0-9_-]+/gi;
					mentions = this.msg.match(pattern);

					if mentions?
						for mention in mentions
							username = mention.substring(1);
							if username is subscription.u.username
								readBy.push(subscription.u.name)

		if readBy.length > 0
			return 'Seen by: ' + readBy.join(', ')

	body: ->
		switch this.t
			when 'r'  then t('Room_name_changed', { room_name: this.msg, user_by: this.u.username })
			when 'au' then t('User_added_by', { user_added: this.msg, user_by: this.u.username })
			when 'ru' then t('User_removed_by', { user_removed: this.msg, user_by: this.u.username })
			when 'ul' then t('User_left', { user_left: this.u.username })
			when 'nu' then t('User_added', { user_added: this.u.username })
			when 'uj' then t('User_joined_channel', { user: this.u.username })
			when 'wm' then t('Welcome', { user: this.u.username })
			when 'rm' then t('Message_removed', { user: this.u.username })
			when 'rtc' then RocketChat.callbacks.run 'renderRtcMessage', this
			else
				if this.u?.username is RocketChat.settings.get('Chatops_Username')
					this.html = this.msg
					message = RocketChat.callbacks.run 'renderMentions', this
					# console.log JSON.stringify message
					return this.html
				this.html = this.msg
				if _.trim(this.html) isnt ''
					this.html = _.escapeHTML this.html
				message = RocketChat.callbacks.run 'renderMessage', this
				# console.log JSON.stringify message
				this.html = message.html.replace /\n/gm, '<br/>'
				return this.html

	system: ->
		return 'system' if this.t in ['s', 'p', 'f', 'r', 'au', 'ru', 'ul', 'nu', 'wm', 'uj', 'rm']
	edited: ->
		return @ets and @t not in ['s', 'p', 'f', 'r', 'au', 'ru', 'ul', 'nu', 'wm', 'uj', 'rm']
	pinned: ->
		return this.pinned
	canEdit: ->
		hasPermission = RocketChat.authz.hasAtLeastOnePermission('edit-message', this.rid)
		isEditAllowed = RocketChat.settings.get 'Message_AllowEditing'
		editOwn = this.u?._id is Meteor.userId()

		return unless hasPermission or (isEditAllowed and editOwn)

		blockEditInMinutes = RocketChat.settings.get 'Message_AllowEditing_BlockEditInMinutes'
		if blockEditInMinutes? and blockEditInMinutes isnt 0
			msgTs = moment(this.ts) if this.ts?
			currentTsDiff = moment().diff(msgTs, 'minutes') if msgTs?
			return currentTsDiff < blockEditInMinutes
		else
			return true

	canDelete: ->
		if RocketChat.authz.hasAtLeastOnePermission('delete-message', this.rid )
			return true

		return RocketChat.settings.get('Message_AllowDeleting') and this.u?._id is Meteor.userId()
	canPin: ->
		return RocketChat.settings.get 'Message_AllowPinning'
	canStar: ->
		return RocketChat.settings.get 'Message_AllowStarring'
	showEditedStatus: ->
		return RocketChat.settings.get 'Message_ShowEditedStatus'
	label: ->
		if @i18nLabel
			return t(@i18nLabel)
		else if @label
			return @label

Template.message.rendered = ->
	context = this.data;
	view = this.view;
	lastNode = this.lastNode
	if lastNode.previousElementSibling?.dataset?.date isnt lastNode.dataset.date
		$(lastNode).addClass('new-day')

	if lastNode.nextElementSibling?.dataset?.date is lastNode.dataset.date
		$(lastNode.nextElementSibling).removeClass('new-day')
	else
		$(lastNode.nextElementSibling).addClass('new-day')

	ul = lastNode.parentElement
	wrapper = ul.parentElement

	if context.urls?.length > 0 and Template.oembedBaseWidget? and RocketChat.settings.get 'API_Embed'
		if context.u?.username not in RocketChat.settings.get('API_EmbedDisabledFor')?.split(',')
			for item in context.urls
				do (item) ->
					urlNode = lastNode.querySelector('.body a[href="'+item.url+'"]')
					if urlNode?
						$(lastNode.querySelector('.body')).append Blaze.toHTMLWithData Template.oembedBaseWidget, item
						$(lastNode.querySelector('.body a[href="'+item.url+'"]')).hide()
