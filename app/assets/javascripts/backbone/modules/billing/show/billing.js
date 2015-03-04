Robin.module('Billing.Show', function(Show, App, Backbone, Marionette, $, _){
  Show.BillingPage = Backbone.Marionette.LayoutView.extend({
    template: 'modules/billing/show/templates/billing',

  });
});