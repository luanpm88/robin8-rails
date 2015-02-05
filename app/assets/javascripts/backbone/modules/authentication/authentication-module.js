Robin.module("Authentication", function(Authentication, Robin, Backbone, Marionette, $, _){

  this.startWithParent = false;

  var API = {
    signIn: function() {
      Authentication.SignIn.Controller.showSignIn();
    },
    signUp: function() {
      Authentication.SignIn.Controller.showSignUp();
    }
  }

  Authentication.Router = Backbone.Marionette.AppRouter.extend({
    routes: {
      "signin": "signIn",
      "signup": "signUp"
    },

    signUp: function() { API.signUp(); },

    signIn: function() { API.signIn(); }

  });

  Robin.addInitializer = function() {
    new Authentication.Router();
  };

  Authentication.on('start', function(){
    API.signIn();
  });
  
});