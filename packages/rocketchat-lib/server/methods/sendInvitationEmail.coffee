Meteor.methods
	sendInvitationEmail: (emails) ->
		if not Meteor.userId()
			throw new Meteor.Error 'invalid-user', "[methods] sendInvitationEmail -> Invalid user"

		for email in emails

			Mandrill.messages.sendTemplate({
				"template_name": "meteor-introduction-to-stitch",
				"template_content": [{}],
				"message": {
					subject: 'Invitation to Stitch',
					from_email: 'support@teamstitch.com',
					from_name: 'Stitch',
					"to": [{"email": email}],
					important: true
				}
			});


		return emails
