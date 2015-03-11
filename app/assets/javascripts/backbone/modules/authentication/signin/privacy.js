Robin.module('Authentication.SignIn', function(SignIn, App, Backbone, Marionette, $, _){

  SignIn.PrivacyView = Backbone.Marionette.ItemView.extend({
    template: 'modules/authentication/signin/templates/privacy',

    onRender: function() {
      $('.signup-tag').text('MYPRGENIE TERMS OF USE, PRIVACY POLICY, AND DISTRIBUTION POLICIES');
    },
    
  });
});