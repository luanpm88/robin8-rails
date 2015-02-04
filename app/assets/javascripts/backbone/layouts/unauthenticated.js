Robin.Views.Layouts.Unauthenticated = Backbone.Marionette.LayoutView.extend({
  template: JST['layouts/unauthenticated'],

  regions: {
    signUpForm: "#signInContainer",
  }
});