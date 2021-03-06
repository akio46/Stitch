RocketChat.models.Mentions = new class extends RocketChat.models._Base
	constructor: ->
		@_initModel 'mentions'

	# INSERT
	createWithUserId: (userId) ->
		record =
			userId: userId

		record._id = @insert record
		return record

	# Find
	findOneByUserId: (userId) ->
		query =
			userId: userId

		return @findOne query

	# REMOVE
	removeByUserId: (userId) ->
		query =
			userId: userId

		return @remove query
