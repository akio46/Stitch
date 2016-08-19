Meteor.startup ->
  Stripe = window.Stripe
  Stripe.setPublishableKey( RocketChat.settings.get 'Stripe_PublishableKey' )
