Robin.module('Billing.Show', function(Show, App, Backbone, Marionette, $, _){
  Show.BillingPage = Backbone.Marionette.ItemView.extend({
    template: 'modules/billing/show/templates/billing',

    events: {
      'click #cancel-subscription' : 'cancelSubscription',
      'click .cancel-addon' : 'cancelAddon'
    },

    initialize: function() {
      var view = this;
      view.collection.fetch().then(function() {
        view.render();
      });
    },

    templateHelpers: {
      count: function(c) {
        if (c == 9999) {
          return "<b>Unlimited</b>";
        } else {
          return "<strong>" + c + "</strong>";
        }
      },
      priceClass: function(slug) {
        var res = "price-amount"
        if (s(slug).startsWith('new')) {
          res = res + "-new";
        }
        return res;
      }
    },

    onRender: function() {
    },

    cancelSubscription: function(event) {
      var view = this;
      var r = this.model;
      swal({
        title: "Cancel current subscription?",
        // text: "You will not be able to recover this post.",
        type: "error",
        showCancelButton: true,
        confirmButtonClass: 'btn-danger',
        confirmButtonText: 'Yes',
        cancelButtonText: "No",
      },
      function(isConfirm) {
        if (isConfirm) {
          Robin.currentUser.cancelSubscription().done(function(data){
            Robin.currentUser = new Robin.Models.User(data);
            $.growl("Your current plan is canceled!", {
              type: "info",
            });
            view.render();
          }).error(function(data){
            $.growl(data.responseJSON.error, {
              type: "danger",
            });
          });
        }
      });
    },

    cancelAddon: function(event) {
      var view = this;
      var id = $(event.target).parents('tr').attr('id');
      console.log(id);
      swal({
        title: "Cancel this add-on?",
        type: "error",
        showCancelButton: true,
        confirmButtonClass: 'btn-danger',
        confirmButtonText: 'Yes',
        cancelButtonText: "No",
      },
      function(isConfirm) {
        if (isConfirm) {
          Robin.currentUser.cancelAddon({id: id}).done(function(data){
            Robin.currentUser = new Robin.Models.User(data)
            $.growl("This addon was canceled!", {
              type: "success",
            });
            view.render();
          }).error(function(data){
            $.growl(data.responseJSON.error, {
              type: "danger",
            });
          });
        }
      });
    },

  });
});
