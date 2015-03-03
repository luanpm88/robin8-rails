Robin.module('Authentication.SignIn', function(SignIn, App, Backbone, Marionette, $, _){

  SignIn.Controller = {

    showSignIn: function(){
      var signInView = this.getSignInView();
      Robin.layouts.unauthenticated.signUpForm.show(signInView);
    },

    showStep1: function(){
      var step1View = this.getStep1View();
      Robin.layouts.unauthenticated.signUpForm.show(step1View);
    },

    showStep2: function(){
      var step2View = this.getStep2View();
      Robin.layouts.unauthenticated.signUpForm.show(step2View);
    },

    showStep3: function(){
      var step3View = this.getStep3View();
      Robin.layouts.unauthenticated.signUpForm.show(step3View);
    },

    showStep4: function(){
      var step4View = this.getStep4View();
      Robin.layouts.unauthenticated.signUpForm.show(step4View);
    },

    showConfirmation: function(){
      var confirmationView = this.getComfirmationView();
      Robin.layouts.unauthenticated.signUpForm.show(confirmationView);
    },

    showForgot: function(){
      var forgotView = this.getForgotView();
      Robin.layouts.unauthenticated.signUpForm.show(forgotView);
    },

    showAccept: function(acceptToken){
      console.log('accept');
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

    getStep1View: function(){
      return new SignIn.Step1View();
    },

    getStep2View: function(){
      return new SignIn.Step2View();
    },

    getStep3View: function(){
      return new SignIn.Step3View();
    },

    getStep4View: function(){
      return new SignIn.Step4View();
    },

    getComfirmationView: function(){
      return new SignIn.ConfirmationView();
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