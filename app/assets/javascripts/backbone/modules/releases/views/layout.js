Robin.module('Releases', function(Releases, App, Backbone, Marionette, $, _){

  Releases.Layout = Marionette.LayoutView.extend({
    template: 'modules/releases/templates/layout',
    regions: {
      topMenuRegion: '.top_menu',
      mainContentRegion: '.row',
      paginationRegion: '.pagination_block'
    }
  });
});

