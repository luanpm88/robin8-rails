var AppLayoutView = Backbone.Marionette.LayoutView.extend({
  template: JST['layouts/not-registered'],

  regions: {
    signUpForm: "#signInContainer",
  }
});