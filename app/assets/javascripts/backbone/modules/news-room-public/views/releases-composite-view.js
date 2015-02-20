// NewsRoomsCollectionView
Robin.module('NewsRoomPublic', function(NewsRoomPublic, App, Backbone, Marionette, $, _){

  NewsRoomPublic.ReleasesCompositeView = Marionette.CompositeView.extend({
    template: 'modules/news-room-public/templates/release-composite-view'
  });

});
