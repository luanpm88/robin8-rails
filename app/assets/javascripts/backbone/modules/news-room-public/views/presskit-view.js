Robin.module('NewsRoomPublic', function(NewsRoomPublic, App, Backbone, Marionette, $, _){

  NewsRoomPublic.PresskitView = Marionette.ItemView.extend({
    template: 'modules/news-room-public/templates/presskit',
  });

});
