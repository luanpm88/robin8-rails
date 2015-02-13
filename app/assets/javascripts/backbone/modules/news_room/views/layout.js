// NewsRoomsLayout
Robin.module('Newsroom', function(Newsroom, App, Backbone, Marionette, $, _){

  Newsroom.Layout = Marionette.LayoutView.extend({
    template: 'modules/news_room/templates/layout',
    regions: {
      topMenuRegion: '.top_menu',
      mainContentRegion: '.row',
      paginationRegion: '.pagination_block'
    }
  });
});

