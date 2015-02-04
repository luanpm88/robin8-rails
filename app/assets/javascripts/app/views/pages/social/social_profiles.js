var connectSocial = function(token, response, provider, currentView){
  authResponse = {
    token: token,
    uid: response.id,
    email: response.email,
    name: response.name,
    provider: provider
  }
  $.ajax({
    type: 'POST',
    url: '/users/connect_social',
    dataType: 'json',
    data: {info: authResponse},
    success: function(data, textStatus, jqXHR) {
      currentView.collection = new Robin.Collections.Identities(data);
      currentView.render();
    },
    error: function(jqXHR, textStatus, errorThrown) {
      $.growl(textStatus, {
        type: "danger",
      });
    }
  });
};

var disconnectSocial = function(provider, currentView){
  $.ajax({
    type: 'DELETE',
    url: '/users/disconnect_social',
    dataType: 'json',
    data: {provider: provider},
    success: function(data, textStatus, jqXHR) {
      currentView.collection = new Robin.Collections.Identities(data);
      currentView.render();
    },
    error: function(jqXHR, textStatus, errorThrown) {
      $.growl(textStatus, {
        type: "danger",
      });
    }
  });
};

var googleCallback = function( authResult ) {
  console.log(window.currentView);
  token = authResult.access_token;
  if (authResult['status']['signed_in']) {
      if (authResult['status']['method'] == 'PROMPT') {
        gapi.client.load('oauth2', 'v2', function () {
          gapi.client.oauth2.userinfo.get().execute(function (response) {
            connectSocial(token, response, 'google_oauth2', window.currentView);
          })
        });
      }
  } else {
    $.growl('Sign-in state: ' + authResult['error'], {
        type: "danger",
      });
  }
}

Robin.Views.SocialProfiles = Backbone.Marionette.ItemView.extend({
  template: JST['pages/social/profiles'],

  events: {
    'click .btn-facebook': 'connectFacebook',
    'click .btn-google-plus': 'connectGoogle',
    'click .disconnect': 'disconnect'
  },

  initialize: function() {
  },

  connectFacebook: function(e) {
    e.preventDefault();
    currentView = this;

    FB.login(function(response) {
      if (response.status === 'connected') {        
        if(response.authResponse) {
          token = response.accessToken
          FB.api('/me', function(response) {
            if (response.verified) {
              connectSocial(token, response, 'facebook', currentView);
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

  connectGoogle: function(e) {
    e.preventDefault();
    window.currentView = this;
    
    gapi.auth.signIn({
      'clientid': '639174820348-qqkeokqa6lh7sirppbme6mpvg1s95na4.apps.googleusercontent.com',
      'cookiepolicy': 'single_host_origin',
      'scope': 'https://www.googleapis.com/auth/userinfo.profile https://www.googleapis.com/auth/userinfo.email',
      'callback': 'googleCallback',
      'approvalprompt': 'force'
    });
  },

  disconnect: function(e) {
    e.preventDefault();
    disconnectSocial($(e.target).attr('name'), this);
  }
});