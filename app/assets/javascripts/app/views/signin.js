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
    },
    error: function(jqXHR, textStatus, errorThrown) {
      $.growl(textStatus, {
        type: "danger",
      });
    }
  });
};


var gplusCallback = function( authResult ) {
  token = authResult.id_token
  if (authResult['status']['signed_in']) {
      if (authResult['status']['method'] == 'PROMPT') {
        gapi.client.load('oauth2', 'v2', function () {
          gapi.client.oauth2.userinfo.get().execute(function (response) {
            signInProcess(token, response, 'google_oauth2');
          })
        });
      }
  } else {
    alert('Sign-in state: ' + authResult['error']);
  }
}

Robin.Views.signInView = Backbone.Marionette.ItemView.extend( {
  template: JST['users/signin'],

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
    
    this.model.save(this.model.attributes, {
      success: function(userSession, response) {
        Robin.currentUser = new Robin.Models.User(response);
        Robin.vent.trigger("authentication:logged_in");
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