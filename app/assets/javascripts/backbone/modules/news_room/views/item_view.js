Robin.module('Newsroom', function(Newsroom, App, Backbone, Marionette, $, _){

  Newsroom.ItemView = Marionette.ItemView.extend({
    template: 'modules/news_room/templates/item_view'
  });
});
