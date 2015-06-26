var disconnectSocial = function(id, currentView){
  $.ajax({
    type: 'DELETE',
    url: '/users/disconnect_social',
    dataType: 'json',
    data: {id: id},
    success: function(data, textStatus, jqXHR) {
      Robin.identities = data;
      currentView.render();
      if (!Robin.KOL) {
        Robin.module("Social").postsView.render();
        Robin.module("Social").tomorrowPostsView.render();
        Robin.module("Social").othersPostsView.render();
        Robin.SaySomething.Say.Controller.showSayView();
      }
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
    template: 'modules/social/show/templates/profiles',

    events: {
      'click .btn-facebook': 'connectProfile',
      'click .btn-google-plus': 'connectProfile',
      'click .btn-twitter': 'connectProfile',
      'click .btn-linkedin': 'connectProfile',
      'click .btn-weibo': 'connectProfile',
      'click .btn-wechat': 'connectProfile',
      'click .disconnect': 'disconnect'
    },

    initialize: function() {
    },

    connectProfile: function(e) {
      e.preventDefault();

      if ($(e.target).children().length != 0) {
        var provider = $(e.target).attr('name');
      } else {
        var provider = $(e.target).parent().attr('name');
      };

      var currentView = this;

      var url = '/users/auth/' + provider,
      params = 'location=0,status=0,width=800,height=600';
      currentView.connect_window = window.open(url, "connect_window", params);

      currentView.interval = window.setInterval((function() {
        if (currentView.connect_window.closed) {
          $.get( "/users/get_identities", function( data ) {
            Robin.identities = data;
            // Robin.setIdentities(data);
            currentView.render();
            if (!Robin.KOL) {
              Robin.module("Social").postsView.render();
              Robin.module("Social").tomorrowPostsView.render();
              Robin.module("Social").othersPostsView.render();
              Robin.SaySomething.Say.Controller.showSayView();
            }
            window.clearInterval(currentView.interval);
          });
        }
      }), 500);
    },

    disconnect: function(e) {
      e.preventDefault();
      disconnectSocial($(e.target).attr('identityid'), this);
    }
  });
});
