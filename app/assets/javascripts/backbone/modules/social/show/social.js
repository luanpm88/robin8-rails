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
      $.get( "/users/identities", function( data ) {
        var viewProfiles = new Show.SocialProfiles({collection: new Robin.Collections.Identities(data)});
        currentView.getRegion('profiles').show(viewProfiles);
        currentView.getRegion('scheduled').show(Robin.module("Social").postsView);
      });
    },
  });
});