Robin.module('ReleasesBlast', function(ReleasesBlast, App, Backbone, Marionette, $, _){

  ReleasesBlast.Layout = Marionette.LayoutView.extend({
    template: 'modules/releases_blast/templates/layout',
    regions: {
      topMenuRegion: '.top-menu',
      tabContentRegion: '.rb-tab-content'
    }
  });
});

