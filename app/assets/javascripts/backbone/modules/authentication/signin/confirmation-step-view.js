Robin.module('Authentication.SignIn', function(SignIn, App, Backbone, Marionette, $, _){

  SignIn.ConfirmationView = Backbone.Marionette.ItemView.extend({
    template: 'modules/authentication/signin/templates/confirmation-step',

  });
});