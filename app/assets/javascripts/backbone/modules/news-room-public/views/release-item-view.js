Robin.module('NewsRoomPublic', function(NewsRoomPublic, App, Backbone, Marionette, $, _){

  NewsRoomPublic.ReleaseItemView = Marionette.ItemView.extend({
    template: 'modules/news-room-public/templates/release-view',
  });
  
});
