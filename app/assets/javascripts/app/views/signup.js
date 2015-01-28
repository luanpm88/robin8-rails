Robin.Views.signUpView = Backbone.Marionette.ItemView.extend( {
  template: JST['users/signup'],

  events: {
    'submit form' : 'signup'
  },

  initialize: function() {
    this.model = new Robin.Models.UserRegistration();
    this.modelBinder = new Backbone.ModelBinder();
  },

  onRender: function() {
    this.modelBinder.bind(this.model, this.el);
  },

  signup: function(e) {
    e.preventDefault();
    this.model.save(this.model.attributes, {
      success: function(userSession, response) {
        console.log('success');
      },
      error: function(userSession, response) {
        console.log('error');
      }
    });
  },

});