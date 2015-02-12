Robin.module('Authentication.SignIn', function(SignIn, App, Backbone, Marionette, $, _){

  SignIn.SignUpView = Backbone.Marionette.ItemView.extend( {
    template: 'modules/authentication/signin/templates/signup',

    events: {
      'submit form' : 'signup',
      'click .btn-facebook' : 'socialSignIn',
      'click .btn-google-plus' : 'socialSignIn',
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
          window.location = '#signin'
          $.growl('You will receive an email with instructions for how to confirm your email address in a few minutes', {
            type: "info",
          });
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

    socialSignIn: function(e) {
      e.preventDefault();
      var currentView = this;
      
      if ($(e.target).children().length != 0) {
        var provider = $(e.target).attr('id');
      } else {
        var provider = $(e.target).parent().attr('id');
      };

      var url = '/users/auth/' + provider,
      params = 'location=0,status=0,width=800,height=600';
      currentView.connect_window = window.open(url, "connect_window", params);

      currentView.interval = window.setInterval((function() {
        if (currentView.connect_window.closed) {
          $.get( "/users/get_current_user", function( data ) {
            window.clearInterval(currentView.interval);
            if (data != undefined) {
              Robin.finishSignIn(data);
            } 
          });
        }
      }), 500);
    }
  });
});

Robin