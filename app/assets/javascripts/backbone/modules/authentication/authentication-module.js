Robin.module("Authentication", function(Authentication, Robin, Backbone, Marionette, $, _){

  this.startWithParent = false;

  var API = {
    signIn: function() {
      Authentication.SignIn.Controller.showSignIn();
    },
    signUp: function() {
      Authentication.SignIn.Controller.showSignUp();
    },
    forgot: function() {
      console.log('fff');
      Authentication.SignIn.Controller.showForgot();
    }
  }

  Authentication.Router = Backbone.Marionette.AppRouter.extend({
    routes: {
      "signin": "signIn",
      "signup": "signUp",
      "forgot": "forgot"
    },

    signUp: function() { API.signUp(); },

    signIn: function() { API.signIn(); },

    forgot: function() { API.forgot(); }

  });

  Robin.addInitializer = function() {
    new Authentication.Router();
  };

  Authentication.on('start', function(){
    API.signIn();
  });
  
});