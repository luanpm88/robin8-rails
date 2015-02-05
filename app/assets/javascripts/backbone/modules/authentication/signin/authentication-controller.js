Robin.module('Authentication.SignIn', function(SignIn, App, Backbone, Marionette, $, _){

  SignIn.Controller = {

    showSignIn: function(){
      var signInView = this.getSignInView();
      Robin.layouts.unauthenticated.signUpForm.show(signInView);
    },

    showSignUp: function(){
      var signUpView = this.getSignUpView();
      Robin.layouts.unauthenticated.signUpForm.show(signUpView);
    },

    getSignInView: function(){
      return new SignIn.SignInView();
    },

    getSignUpView: function(){
      return new SignIn.SignUpView();
    }

  };

});