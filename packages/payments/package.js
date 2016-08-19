Package.describe({
  summary: "Stripe payments for Stitch",
  version: "0.0.1",
  name: "payments"
});

Package.onUse(function(api) {
  api.versionsFrom('1.0');
  api.use([
      'coffeescript',
      'rocketchat:lib@0.0.1',
      'mrgalaxy:stripe@2.2.0',
      'dburles:collection-helpers@1.0.4',
      'aldeed:simple-schema@1.3.3',
      'aldeed:collection2@2.5.0',
      'matb33:collection-hooks@0.7.15',
      'less@2.5.1',
      'templating',
      'reactive-var',
      'momentjs:moment@2.10.6'
  ],['client','server']);

  // COMMON
  api.addFiles([
    'lib/payment.coffee',
    'lib/payment-history.coffee',
    'lib/subscriptions.coffee',
    'lib/hooks.coffee',
  ], ['client','server']);
  
  // CLIENT
  api.addFiles([
    'client/startup.coffee',
    'client/subscribe.html',
    'client/subscribe.coffee',
    'client/jquery.creditCardValidator.coffee',
    'client/style.less',
  ], 'client');

  // SERVER
  api.addFiles([
    'server/methods.coffee',
    'server/publish.coffee',
  ], 'server');
  
  api.export([
      'Subscriptions',
      'PaymentHistory',
      'Currency'
  ]);

});
