Robin.module('Releases.Show', function(Show, App, Backbone, Marionette, $, _){
  Show.ReleasesPage = Backbone.Marionette.LayoutView.extend({
    template: 'modules/releases/show/templates/releases',

    regions: {
      releases: "#releases"
    },

    initialize: function() {
    },

    onRender: function() {
      var currentView = this;
      var releasesView = new Show.ReleasesComposite({ collection: new Robin.Collections.Releases() });
        currentView.getRegion('releases').show(releasesView);
    },
  });
});