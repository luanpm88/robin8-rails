Robin.module('Social.Show', function(Show, App, Backbone, Marionette, $, _){
  Show.SocialPage = Backbone.Marionette.LayoutView.extend({
    template: 'modules/social/show/templates/social',

    regions: {
      profiles: "#social-profiles",
      scheduled: "#social-scheduled",
    },

    initialize: function() {
    },

    onRender: function() {
      var currentView = this;
      var postsView = new Show.ScheduledPosts();
      var profilesView = new Show.SocialProfiles();
      
      currentView.getRegion('profiles').show(profilesView);
      currentView.getRegion('scheduled').show(postsView);
    },
  });
});