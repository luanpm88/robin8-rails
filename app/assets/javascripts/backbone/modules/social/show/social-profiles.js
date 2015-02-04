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

var connectSocial = function(token, response, provider, currentView){
  authResponse = {
    token: token || null,
    uid: response.id,
    email: response.email || '',
    name: response.name || (response.firstName + ' ' + response.lastName),
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

Robin.module('Social.Show', function(Show, App, Backbone, Marionette, $, _){

  Show.SocialProfiles = Backbone.Marionette.ItemView.extend({
    template: JST['pages/social/profiles'],

    events: {
      'click .btn-facebook': 'connectFacebook',
      'click .btn-google-plus': 'connectGoogle',
      'click .btn-twitter': 'connectTwitter',
      'click .btn-linkedin': 'connectLinkedin',
      'click .disconnect': 'disconnect'
    },

    initialize: function() {
      console.log('init social profile pages');
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

    connectTwitter: function(e) {
      e.preventDefault();
      
      authResponse = {
        oauth_consumer_key: "chfbNFBkf56gJT2BDzmCNNfgv", 
        oauth_nonce: "74a3f508a9a7384b7283751518e17bda", 
        oauth_signature: "vR6oMDbA2BDqz8DpNctNimqeCGw%3D", 
        oauth_signature_method: "HMAC-SHA1", 
        oauth_token: "1277473896-KtaOxg0DgAqz5gVHEiGC7p8nKNHj5InRNvVEYVU", 
        oauth_version: "1.0"
      };

      $.ajax({
        type: 'POST',
        url: 'https://api.twitter.com/oauth/authenticate',
        dataType: 'json',
        data: authResponse,
        success: function(data, textStatus, jqXHR) {
          console.log(data);
          // currentView.collection = new Robin.Collections.Identities(data);
          // currentView.render();
        },
        error: function(jqXHR, textStatus, errorThrown) {
          $.growl(textStatus, {
            type: "danger",
          });
        }
      });
    },

    connectLinkedin: function(e) {
      e.preventDefault();
      currentView = this;

      IN.User.authorize(function() {
        IN.API.Profile("me").result( function(me) {
          connectSocial('', me.values[0], 'linkedin', currentView);
        });
      });
    },

    disconnect: function(e) {
      e.preventDefault();
      disconnectSocial($(e.target).attr('name'), this);
    }
  });
});