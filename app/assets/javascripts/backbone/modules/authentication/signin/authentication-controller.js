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

    showForgot: function(){
      var forgotView = this.getForgotView();
      Robin.layouts.unauthenticated.signUpForm.show(forgotView);
    },

    showAccept: function(acceptToken){
      var acceptView = this.getAcceptView(acceptToken);
      Robin.layouts.unauthenticated.signUpForm.show(acceptView);
    },

    showReset: function(resetToken){
      var resetView = this.getResetView(resetToken);
      Robin.layouts.unauthenticated.signUpForm.show(resetView);
    },

    getSignInView: function(){
      return new SignIn.SignInView();
    },

    getSignUpView: function(){
      return new SignIn.SignUpView();
    },

    getForgotView: function(){
      return new SignIn.ForgotView();
    },

    getAcceptView: function(acceptToken){
      return new SignIn.AcceptView({acceptToken: acceptToken});
    },

    getResetView: function(resetToken){
      return new SignIn.ResetView({resetToken: resetToken});
    }

  };

});