Robin.module('NewsRoomPublic', function(NewsRoomPublic, App, Backbone, Marionette, $, _){

  NewsRoomPublic.SidebarView = Marionette.ItemView.extend({
    template: 'modules/news-room-public/templates/sidebar',
  });
});
