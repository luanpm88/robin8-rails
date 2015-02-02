Robin.Views.Navigation = Backbone.Marionette.ItemView.extend({
  template: JST['pages/navigation'],

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
    console.log('navigation');
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
    Robin.layouts.main.getRegion('content').show(new Robin.Views.Social());
  },

  showAnalytics: function() {
    console.log('showAnalytics');
  },

  showProfile: function() {
    Robin.layouts.main.getRegion('content').show(new Robin.Views.Profile());
  },
  
});