Robin.module('Authentication.SignIn', function(SignIn, App, Backbone, Marionette, $, _){

  SignIn.SignUpView = Backbone.Marionette.ItemView.extend( {
    template: 'modules/authentication/signin/templates/signup',

    events: {
      'submit form' : 'signup',
      'click .btn-facebook' : 'loginFB',
      'click .btn-google-plus' : 'loginGoogle',
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

    loginFB: function(e) {
      e.preventDefault();
      
      FB.login(function(response) {
        if (response.status === 'connected') {        
          if(response.authResponse) {
            token = response.accessToken
            FB.api('/me', function(response) {
              if (response.verified) {
                signInProcess(token, response, 'facebook');
              } else {
                $.growl('Your Facebook account is not verified', {
                  type: "danger",
                });
              }
            });
          }
        } else if (response.status === 'not_authorized') {
          $.growl('The person is logged into Facebook, but not your app.', {
            type: "danger",
          });
        } else {
          $.growl("The person is not logged into Facebook, so we're not sure if they are logged into this app or not.", {
            type: "danger",
          });

        }
      });
    },

    loginGoogle: function(e) {
      e.preventDefault();
      
      gapi.auth.signIn({
        'clientid': window.google_api_key,
        'cookiepolicy': 'single_host_origin',
        'scope': 'https://www.googleapis.com/auth/userinfo.profile https://www.googleapis.com/auth/userinfo.email',
        'callback': 'gplusCallback',
        'approvalprompt': 'force'
      });
    }

  });
});