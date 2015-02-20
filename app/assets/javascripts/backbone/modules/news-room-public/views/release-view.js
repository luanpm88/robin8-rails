Robin.module('NewsRoomPublic', function(NewsRoomPublic, App, Backbone, Marionette, $, _){

  NewsRoomPublic.ReleaseView = Marionette.ItemView.extend({
    template: 'modules/news-room-public/templates/_release-view',
    tagName: 'div',
    className: 'col-sm-6 col-md-4'
  });
  
});
