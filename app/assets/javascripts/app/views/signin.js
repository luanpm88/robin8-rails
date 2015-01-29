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

    el = $(this.el);
    
    this.model.save(this.model.attributes, {
      success: function(userSession, response) {
        Robin.currentUser = new Robin.Models.User(response);
      },
      error: function(userSession, response) {
        var result = $.parseJSON(response.responseText);
        $.growl(result.error, {
          type: "danger",
        });
      }
    });
  },

});