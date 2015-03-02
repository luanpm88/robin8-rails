Robin.module('Authentication.SignIn', function(SignIn, App, Backbone, Marionette, $, _){

  SignIn.Step1View = Backbone.Marionette.ItemView.extend({
    template: 'modules/authentication/signin/templates/step1',

    initialize: function() {
      // Robin.layouts.unauthenticated = new Robin.Views.Layouts.Unauthenticated();
      // Robin.main.show(Robin.layouts.unauthenticated);
    },

    onRender: function() {
      $('html, body').animate({
        scrollTop: 0
      }, 600);
    },

  });
});
