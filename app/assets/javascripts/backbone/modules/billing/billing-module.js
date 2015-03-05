Robin.module("Billing", function(Billing, Robin, Backbone, Marionette, $, _){

  this.startWithParent = false;

  var API = {
    showBillingPage: function() {
      Billing.Show.Controller.showBillingPage();
    }
  }

  Billing.on('start', function(){
    API.showBillingPage();
  })
});