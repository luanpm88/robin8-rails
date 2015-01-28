Robin.Views.signInView = Backbone.Marionette.ItemView.extend( {
  template: JST['users/signin'],

  events: {
    'submit form' : 'login'
  },

  initialize: function() {
    this.model = new Robin.Models.UserSession();
    this.modelBinder = new Backbone.ModelBinder();
  },

  onRender: function() {
    this.modelBinder.bind(this.model, this.el);
  },

  login: function(e) {
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