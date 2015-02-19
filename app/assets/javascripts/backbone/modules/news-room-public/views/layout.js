// NewsRoomsLayout
Robin.module('NewsRoomPublic', function(Newsroom, App, Backbone, Marionette, $, _){

  Newsroom.Layout = Marionette.LayoutView.extend({
    template: 'modules/news-room-public/templates/layout',
    regions: {
      sidebar: '#sidebar-wrapper',
      content: '#page-content-wrapper'
    }
  });
});

