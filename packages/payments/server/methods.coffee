Stripe = StripeAPI( RocketChat.settings.get 'Stripe_SecretKey' )
Future = Npm.require('fibers/future')
Fiber = Npm.require('fibers')

Meteor.methods
  'paymentsCreateCustomer': (token, email) ->
    check token, String
    check email, String
    stripeCustomer = new Future
    Stripe.customers.create {
      source: token
      email: email
    }, (error, customer) ->
      if error
        stripeCustomer.return error
      else
        stripeCustomer.return customer
      return
    stripeCustomer.wait()

  'paymentsCreateSubscription': ->
    #stripe.customers.createSubscription

  'paymentsUpdateSubscription': ->
    #stripe.customers.updateSubscription
    
  'paymentsRetrieveSubscription': ->
    #stripe.customers.retrieveSubscription

  'paymentsUpdateCustomer': ->
    #stripe.customers.update
  
  'paymentsRetrieveCustomer': ->
    #stripe.customers.retrieve
  
  'paymentsUpdateCustomerCard': ->
    #stripe.customers.updateCard

  'paymentsCancelSubscription': ->
    #stripe.customers.cancelSubscription
    
  'paymentsListCustomerSubscription': ->
    #stripe.customers.listSubscriptions
