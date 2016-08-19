Template.subscribe.onRendered ->

Template.subscribe.helpers
	storedCards:->
		return false

Template.subscribe.events
	'click .make-payment': (e,t)->
		$('.make-payment').prop('disabled', true);
		ccNum = $('[data-stripe="number"]').val()
		expMo = $('[data-stripe="exp-month"]').val()
		expYr = $('[data-stripe="exp-year"]').val()
		cvc = $('[data-stripe="cvc"]').val()

		Stripe.card.createToken(
		  number: ccNum,
		  exp_month: expMo,
		  exp_year: expYr,
		  cvc: cvc,
		 	(status, res) -> 
		    # stripeToken = res.id
		    # Meteor.call('', stripeToken)
		    console.log status
		    console.log res
		)