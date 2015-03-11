Robin.module('Billing.Show', function(Show, App, Backbone, Marionette, $, _){

  Show.Controller = {

    showBillingPage: function(){
      var billingView = this.getBillingPageView();
      Robin.layouts.main.content.show(billingView);
    },

    getBillingPageView: function(){
      return new Show.BillingPage({collection: new Robin.Collections.Payments()});;
    },
  }

});