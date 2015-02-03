Robin.Views.Layouts.Social = Backbone.Marionette.LayoutView.extend({
  template: JST['pages/social/social'],

  regions: {
    profiles: "#social-profiles",
    scheduled: "#social-scheduled",
  },

  initialize: function() {
  },

  onRender: function() {
    currentView = this;
    var postsView = new Robin.Views.ScheduledPosts();
    $.get( "/users/identities", function( data ) {
      var viewPosts = new Robin.Views.SocialProfiles({collection: new Robin.Collections.Identities(data)});
      currentView.getRegion('profiles').show(viewPosts);
      currentView.getRegion('scheduled').show(postsView);
    });
  },
});