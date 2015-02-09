Robin.module('Navigation.Show', function(Show, App, Backbone, Marionette, $, _){

  Show.NavigationView = Backbone.Marionette.ItemView.extend({
    template: 'modules/navigation/show/templates/navigation',
    events: {
      'click #nav-dashboard': 'showDashboard',
      'click #nav-robin8': 'showRobin',
      'click #nav-monitoring': 'showMonitoring',
      'click #nav-newsrooms': 'showNews',
      'click #nav-releases': 'showReleases',
      'click #nav-social': 'showSocial',
      'click #nav-analytics': 'showAnalytics',
      'click #nav-profile': 'showProfile',
    },

    initialize: function() {
    },

    showDashboard: function() {
      console.log('showDashboard');
    },

    showRobin: function() {
      console.log('showRobin');
    },

    showMonitoring: function() {
      console.log('showMonitoring');
    },

    showNews: function() {
      console.log('showNews');
    },

    showReleases: function() {
      console.log('showReleases');
    },

    showSocial: function() {
      if (Robin.Social._isInitialized){
        Robin.Social.Show.Controller.showSocialPage();
      } else {
        Robin.module('Social').start();
      }
    },

    showAnalytics: function() {
      console.log('showAnalytics');
    },

    showProfile: function() {
      console.log('showProfile');
      Robin.module('Profile').start();
    },
  });

});