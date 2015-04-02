Robin.module('Social.Show', function(Show, App, Backbone, Marionette, $, _){
  Show.SocialPage = Backbone.Marionette.LayoutView.extend({
    template: 'modules/social/show/templates/social',

    regions: {
      profiles: "#social-profiles",
      scheduled: "#social-scheduled",
      tomorrowScheduled: "#social-scheduled",
    },

    onRender: function() {
      var currentView = this;
      $.get( "/users/identities", function( data ) {
        var viewProfiles = new Show.SocialProfiles({collection: new Robin.Collections.Identities(data)});
        currentView.getRegion('profiles').show(viewProfiles);
        currentView.getRegion('scheduled').show(Robin.module("Social").generalView);
        if (_.last(window.location.href.split('/')) == 'posts') {
          currentView.$el.find('li.posts a').tab('show');
        } else if (_.last(window.location.href.split('/')) == 'profiles') {
          currentView.$el.find('li.profiles a').tab('show');
        }
      });
    },

    onShow: function() {
      var currentView = this;
      $('.profiles a[data-toggle="tab"]').on('shown.bs.tab', function() {
        Robin.vent.trigger("social:networksClicked");
      })
      Robin.vent.on("social:showPosts", function() {
        currentView.$el.find('li.posts a').tab('show');
      });
      Robin.vent.on("social:showProfiles", function() {
        currentView.$el.find('li.profiles a').tab('show');
      });
    },

  });
});