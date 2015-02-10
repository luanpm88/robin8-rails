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
      var postsCollection = new Robin.Collections.Posts();
      var postsView = new Show.ScheduledPostsComposite({ collection: new Robin.Collections.Posts() });
      $.get( "/users/identities", function( data ) {
        var viewPosts = new Show.SocialProfiles({collection: new Robin.Collections.Identities(data)});
        currentView.getRegion('profiles').show(viewPosts);
        currentView.getRegion('scheduled').show(postsView);
      });
    },
  });
});