var gplusCallback = function( authResult ) {
  token = authResult.access_token
  if (authResult['status']['signed_in']) {
      if (authResult['status']['method'] == 'PROMPT') {
        gapi.client.load('oauth2', 'v2', function () {
          gapi.client.oauth2.userinfo.get().execute(function (response) {
            signInProcess(token, response, 'google_oauth2');
          })
        });
      }
  } else {
    $.growl('Sign-in state: ' + authResult['error'], {
        type: "danger",
      });
  }
};

var signInProcess = function(token, response, provider){
  authResponse = {
    token: token,
    uid: response.id,
    email: response.email,
    name: response.name,
    remember_me: response.remember_me,
    provider: provider
  }
  $.ajax({
    type: 'POST',
    url: '/users/login_by_social',
    dataType: 'json',
    data: {info: authResponse},
    success: function(data, textStatus, jqXHR) {
      Robin.currentUser = new Robin.Models.User(data);
      Robin.vent.trigger("authentication:logged_in");
      $('body#main').removeClass('login');
      Robin.navigate('/');
    },
    error: function(jqXHR, textStatus, errorThrown) {
      $.growl(textStatus, {
        type: "danger",
      });
    }
  });
};

Robin.module("Authentication", function(Authentication, Robin, Backbone, Marionette, $, _){

  this.startWithParent = false;

  var API = {
    signIn: function() {
      Authentication.SignIn.Controller.showSignIn();
    },
    signUp: function() {
      Authentication.SignIn.Controller.showSignUp();
    },
    forgot: function() {
      Authentication.SignIn.Controller.showForgot();
    }
  }

  Authentication.Router = Backbone.Marionette.AppRouter.extend({
    routes: {
      "signin": "signIn",
      "signup": "signUp",
      "forgot": "forgot"
    },

    signUp: function() { API.signUp(); },

    signIn: function() { API.signIn(); },

    forgot: function() { API.forgot(); }

  });

  Robin.addInitializer = function() {
    new Authentication.Router();
  };

  Authentication.on('start', function(){
    API.signIn();
  });
  
});