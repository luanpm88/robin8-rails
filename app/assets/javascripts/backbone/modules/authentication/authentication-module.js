Robin.module("Authentication", function(Authentication, Robin, Backbone, Marionette, $, _){

  this.startWithParent = false;

  var API = {
    signIn: function() {
      Authentication.SignIn.Controller.showSignIn();
    },
    step1: function() {
      Authentication.SignIn.Controller.showStep1();
    },
    step2: function() {
      Authentication.SignIn.Controller.showStep2();
    },
    step3: function() {
      Authentication.SignIn.Controller.showStep3();
    },
    step4: function() {
      Authentication.SignIn.Controller.showStep4();
    },
    confirmationStep: function() {
      Authentication.SignIn.Controller.showConfirmation();
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
      "": "signIn",
      "signin": "signIn",
      "step1": "step1",
      "step2": "step2",
      "step3": "step3",
      "step4": "step4",
      "confirmation-step": "confirmationStep",
      "forgot": "forgot",
      "accept/:acceptToken": "accept",
      "reset/:resetToken": "reset",
    },

    // signUp: function() { API.signUp(); },

    step1: function() { API.step1(); },

    step2: function() { API.step2(); },

    step3: function() { API.step3(); },

    step4: function() { API.step4(); },

    confirmationStep: function() { API.confirmationStep(); },

    accept: function(acceptToken) {API.accept(acceptToken);},

    reset: function(resetToken) {API.reset(resetToken);},

  });

  Robin.addInitializer = function() {
    // new Authentication.Router();
  };

  Authentication.on('start', function(){
    new Authentication.Router();
    $('body').addClass('login');
    API.signIn();
  });
  
});
