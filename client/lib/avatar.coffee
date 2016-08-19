@getAvatarUrlFromUsername = (username) ->
	key = "avatar_random_#{username}"
	unless Session.get(key)?
		random = Math.floor((Math.random() * 500) + 1)
		Session.set(key, random)

	avatarRandom = Session.get(key)
	if not username?
		return

	if Meteor.isCordova
		path = Meteor.absoluteUrl()
	else
		path = '/'
	return "#{path}avatar/#{username}.jpg?_dc=#{avatarRandom}"

Blaze.registerHelper 'avatarUrlFromUsername', getAvatarUrlFromUsername

@getAvatarAsPng = (username, cb) ->
	image = new Image
	image.src = getAvatarUrlFromUsername(username)

	image.onload = ->
		canvas = document.createElement('canvas')
		canvas.width = image.width
		canvas.height = image.height
		context = canvas.getContext('2d')
		context.drawImage(image, 0, 0)
		cb canvas.toDataURL('image/png')
	image.onerror = ->
		cb ''

@updateAvatarOfUsername = (username) ->
	key = "avatar_random_#{username}"
	Session.set key, Math.round(Math.random() * 1000)

	for key, room of RoomManager.openedRooms
		url = getAvatarUrlFromUsername username

		$(room.dom).find(".message[data-username='#{username}'] .avatar-image").css('background-image', "url(#{url})");

	return true
