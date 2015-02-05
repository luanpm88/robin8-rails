Robin.module('Authentication.SignIn', function(SignIn, App, Backbone, Marionette, $, _){

  SignIn.SignUpView = Backbone.Marionette.ItemView.extend( {
    template: 'modules/authentication/signin/templates/signup',

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
      
      el = $(this.el);
      el.find('.controls').removeClass('error');

      this.model.save(this.model.attributes, {
        success: function(userSession, response) {
          Robin.currentUser = new Robin.Models.User(response);
          Robin.vent.trigger("authentication:logged_in");
        },
        error: function(userSession, response) {
          var result = $.parseJSON(response.responseText);
          _(result.errors).each(function(errors,field) {
            $('input[name=' + field + ']').addClass('error');
            _(errors).each(function(error, i) {
              formatted_field = s(field).capitalize().value().replace('_', ' ');
              
              $.growl(formatted_field + ' ' + error, {
                type: "danger",
              });
            });
          });
        }
      });
    },

  });
});