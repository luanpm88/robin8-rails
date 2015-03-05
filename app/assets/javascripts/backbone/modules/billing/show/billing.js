Robin.module('Billing.Show', function(Show, App, Backbone, Marionette, $, _){
  Show.BillingPage = Backbone.Marionette.LayoutView.extend({
    template: 'modules/billing/show/templates/billing',

    events: {
      'change #subscription-selector': 'showForm',
    },

    initialize: function() {
      this.packages = new Robin.Collections.Packages();
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

    showForm: function() {
      this.$el.find('#checkout-form').removeClass('hidden');
      this.model = new Robin.Models.Subscription();
    },

  });
});