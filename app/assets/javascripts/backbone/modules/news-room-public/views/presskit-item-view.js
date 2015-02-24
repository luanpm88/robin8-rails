Robin.module('NewsRoomPublic', function(NewsRoomPublic, App, Backbone, Marionette, $, _){

  NewsRoomPublic.PresskitItemView = Marionette.ItemView.extend({
    
    template: 'modules/news-room-public/templates/_presskit-item',
    model: Robin.Models.Attachment
    
  });

});
