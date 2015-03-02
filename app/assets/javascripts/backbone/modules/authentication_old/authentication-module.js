Robin.module("AuthenticationOld", function(AuthenticationOld, Robin, Backbone, Marionette, $, _){

  this.startWithParent = false;

  var API = {
    signIn: function() {
      AuthenticationOld.SignIn.Controller.showSignIn();
    },
    signUp: function() {
      AuthenticationOld.SignIn.Controller.showSignUp();
    },
    forgot: function() {
      AuthenticationOld.SignIn.Controller.showForgot();
    },
    accept: function(acceptToken) {
      AuthenticationOld.SignIn.Controller.showAccept(acceptToken);
    },
    reset: function(resetToken) {
      AuthenticationOld.SignIn.Controller.showReset(resetToken);
    },
  }

  AuthenticationOld.Router = Backbone.Marionette.AppRouter.extend({
    routes: {
      "": "signIn",
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
    // new AuthenticationOld.Router();
  };

  AuthenticationOld.on('start', function(){
    new AuthenticationOld.Router();
    $('body#main').addClass('login');
    API.signIn();
  });
  
});