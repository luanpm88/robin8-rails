Robin.module('Authentication.SignIn', function(SignIn, App, Backbone, Marionette, $, _){

  SignIn.PrivacyView = Backbone.Marionette.ItemView.extend({
    template: 'modules/authentication/signin/templates/privacy',

    onRender: function() {
      $('.signup-tag').text('ROBIN8 INC TERMS OF USE, PRIVACY POLICY, AND DISTRIBUTION POLICIES');
    },
    
  });
});