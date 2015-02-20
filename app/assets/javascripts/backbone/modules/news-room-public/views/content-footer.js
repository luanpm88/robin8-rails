Robin.module('NewsRoomPublic', function(NewsRoomPublic, App, Backbone, Marionette, $, _){

  NewsRoomPublic.ContentFooterView = Marionette.ItemView.extend({
    template: 'modules/news-room-public/templates/content-footer',
  });
  
});
