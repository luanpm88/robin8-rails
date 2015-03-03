Robin.Views.Layouts.Unauthenticated = Backbone.Marionette.LayoutView.extend({
  template: 'layouts/templates/unauthenticated',

  regions: {
    signUpForm: ".form-step",
  },

  initialize: function() {
    $(document).foundation();
  },

});