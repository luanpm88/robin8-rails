Robin.module('Billing.Show', function(Show, App, Backbone, Marionette, $, _){
  Show.BillingPage = Backbone.Marionette.ItemView.extend({
    template: 'modules/billing/show/templates/billing',

    events: {
      'change #subscription-selector': 'showForm',
      'ajax:error #checkout-form' : 'errorSubmit',
      'ajax:success #checkout-form' : 'successSubmit',
      'click #cancel-subscription' : 'cancelSubscription'
    },

    initialize: function() {
      this.collection.fetch();
      this.packages = new Robin.Collections.Packages();
      BlueSnap.publicKey = BLueSnapKeys.publicKey;
    },

    onRender: function() {
      var view = this;
      view.packages.fetch({
        success: function(package, response, options) {
          _.each(response, function(value) {             
            view.$el.find('#subscription-selector').append($("<option></option>")
              .attr("value",value.id)
              .text(value.name))
          });
        }
      });
    },

    showForm: function(e) {
      this.$el.find('#checkout-form').removeClass('hidden');
      this.$el.find('input[name="package_id"]').val(this.$el.find('#subscription-selector').val());
      BlueSnap.setTargetFormId("checkout-form");
    },

    successSubmit: function(event, data) {
      $.growl('Your package was updated',{
        type: 'success'
      });
      this.render();
    },

    errorSubmit: function(event, data) {
      _(data.responseJSON).each(function(error, i) {
        $.growl(error, {
          type: "danger",
        });
      });
    },

    cancelSubscription: function(event) {
      Robin.currentUser.cancelSubscription().done(function(data){
        window.location.href = '/users/sign_out'
      });
    },

  });
});