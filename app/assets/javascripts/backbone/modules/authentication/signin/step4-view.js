Robin.module('Authentication.SignIn', function(SignIn, App, Backbone, Marionette, $, _){

  SignIn.Step4View = Backbone.Marionette.ItemView.extend({
    template: 'modules/authentication/signin/templates/step4',

    onRender: function() {
      $('html, body').animate({
        scrollTop: 0
      }, 600);
    },
  });
});