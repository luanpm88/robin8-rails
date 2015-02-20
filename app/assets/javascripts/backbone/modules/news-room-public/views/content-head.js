Robin.module('NewsRoomPublic', function(NewsRoomPublic, App, Backbone, Marionette, $, _){

  NewsRoomPublic.ContentHeadView = Marionette.ItemView.extend({
    template: 'modules/news-room-public/templates/content-head',
  });
  
});
