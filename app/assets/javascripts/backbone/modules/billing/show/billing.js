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

    onRender: function() {
    },

    cancelSubscription: function(event) {
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
            $.growl("Your current plan is canceled!", {
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
            $.growl("Your current plan is canceled!", {
              type: "success",
            });
            view.render();
          }).error(function(data){
            $.growl(data.responseJSON.error, {
              type: "danger",
            });
          });;
        }
      });
    },

  });
});