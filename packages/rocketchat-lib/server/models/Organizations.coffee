RocketChat.models.Organizations = new class extends RocketChat.models._Base
	constructor: ->
		@_initModel 'organizations'

	# INSERT
	createWithNameAndDomain: (name, domain, initCount) ->
		record =
			name: name
			domains: [domain]
			userCount: initCount

		record._id = @insert record
		return record

	# Find
	findOneByDomain: (domain) ->
		query =
			domains: domain

		return @findOne query

	findOneById: (_id) ->
		query =
			_id: _id

		return @findOne query

	# Update
	updateOrgUserCountById: (_id, inc=1) ->
		query =
			_id: _id

		update =
			$inc:
				userCount: inc

		return @update query, update

	editOrgName: (_id, name) ->
		query =
			_id: _id

		update =
			$set:
				'name': name

		@update query, update

		return @findOneById(_id)

	addDomainToOrg: (_id, domain) ->
		org = @findOneByDomain domain
		if org?
			throw new Meteor.Error 'Domain already exists'
		query =
			_id: _id

		update =
			$push:
				'domains': domain

		@update query, update

		return @findOneById(_id)

	removeDomainFromOrg: (_id, domain) ->
		query =
			_id: _id

		update =
			$pull:
				'domains': domain

		@update query, update

		return @findOneById(_id)
