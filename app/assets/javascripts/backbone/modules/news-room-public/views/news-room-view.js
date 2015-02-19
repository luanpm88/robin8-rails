Robin.module('NewsRoomPublic', function(NewsRoomPublic, App, Backbone, Marionette, $, _){

  NewsRoomPublic.NewsRoomView = Marionette.ItemView.extend({
    template: 'modules/news-room-public/templates/news-room',
  });
});
