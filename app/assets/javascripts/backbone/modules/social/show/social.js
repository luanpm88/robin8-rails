Robin.module('Social.Show', function(Show, App, Backbone, Marionette, $, _){
  Show.SocialPage = Backbone.Marionette.LayoutView.extend({
    template: JST['pages/social/social'],

    regions: {
      profiles: "#social-profiles",
      scheduled: "#social-scheduled",
    },

    initialize: function() {
    },

    onRender: function() {
      var currentView = this;
      var postsView = new Show.ScheduledPosts();
      $.get( "/users/identities", function( data ) {
        var viewPosts = new Show.SocialProfiles({collection: new Robin.Collections.Identities(data)});
        currentView.getRegion('profiles').show(viewPosts);
        currentView.getRegion('scheduled').show(postsView);
      });
    },
  });
});