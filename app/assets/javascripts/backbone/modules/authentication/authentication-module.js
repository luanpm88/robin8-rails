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
      Authentication.SignIn.Controller.showForgot();
    },
    accept: function(acceptToken) {
      Authentication.SignIn.Controller.showAccept(acceptToken);
    },
    reset: function(resetToken) {
      Authentication.SignIn.Controller.showReset(resetToken);
    },
  }

  Authentication.Router = Backbone.Marionette.AppRouter.extend({
    routes: {
      "signin": "signIn",
      "signup": "signUp",
      "forgot": "forgot",
      "accept/:acceptToken": "accept",
      "reset/:resetToken": "reset",
    },

    signUp: function() { API.signUp(); },

    signIn: function() { API.signIn(); },

    forgot: function() { API.forgot(); },

    accept: function(acceptToken) {API.accept(acceptToken);},

    reset: function(resetToken) {API.reset(resetToken);},

  });

  Robin.addInitializer = function() {
    new Authentication.Router();
  };

  Authentication.on('start', function(){
    API.signIn();
  });
  
});