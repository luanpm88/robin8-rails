Robin.module('Authentication.SignIn', function(SignIn, App, Backbone, Marionette, $, _){

  SignIn.Step3View = Backbone.Marionette.ItemView.extend({
    template: 'modules/authentication/signin/templates/step3',

    onRender: function() {
      $('html, body').animate({
        scrollTop: 0
      }, 600);
    },
    
  });
});