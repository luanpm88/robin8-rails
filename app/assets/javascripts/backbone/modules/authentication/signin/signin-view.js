Robin.module('Authentication.SignIn', function(SignIn, App, Backbone, Marionette, $, _){

  SignIn.SignInView = Backbone.Marionette.ItemView.extend({
    template: 'modules/authentication/signin/templates/signin',

    events: {
      'submit form' : 'login',
      'click .btn-facebook' : 'loginFB',
      'click .btn-google-plus' : 'loginGoogle',
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

      this.modelBinder.copyViewValuesToModel();
      
      this.model.save(this.model.attributes, {
        success: function(userSession, response) {
          Robin.currentUser = new Robin.Models.User(response);
          Robin.vent.trigger("authentication:logged_in");
          $('body#main').removeClass('login');
          Robin.navigate('/');
        },
        error: function(userSession, response) {
          var result = $.parseJSON(response.responseText);
          $.growl(result.error, {
            type: "danger",
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
        'clientid': '639174820348-qqkeokqa6lh7sirppbme6mpvg1s95na4.apps.googleusercontent.com',
        'cookiepolicy': 'single_host_origin',
        'scope': 'https://www.googleapis.com/auth/userinfo.profile https://www.googleapis.com/auth/userinfo.email',
        'callback': 'gplusCallback',
        'approvalprompt': 'force'
      });
    }
  });
});