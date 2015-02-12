Robin.module('Navigation.Show', function(Show, App, Backbone, Marionette, $, _){

  Show.NavigationView = Backbone.Marionette.ItemView.extend({
    template: 'modules/navigation/show/templates/navigation',
    events: {
      'click #nav-dashboard': 'showDashboard',
      'click #nav-robin8': 'showRobin',
      'click #nav-monitoring': 'showMonitoring',
      'click #nav-newsrooms': 'showNewsRooms',
      'click #nav-releases': 'showReleases',
      'click #nav-social': 'showSocial',
      'click #nav-analytics': 'showAnalytics',
      'click #nav-profile': 'showProfile',
    },

    initialize: function() {
    },

    stopOtherModules: function(){
      _.each(['Newsroom', 'Social', 'Profile'], function(module){
        Robin.module(module).stop();
      });
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

    showNewsRooms: function() {
      this.stopOtherModules();
      Robin.module("Newsroom").start();
      Robin.module("Newsroom").controller.index();
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
      if (Robin.Profile._isInitialized){
        Robin.Profile.Show.Controller.showProfilePage();
      } else {
        Robin.module('Profile').start();
      }
    },
  });

});