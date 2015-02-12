Robin.module('Newsroom', function(Newsroom, App, Backbone, Marionette, $, _){

  Newsroom.TopMenuView = Marionette.ItemView.extend({
    template: 'modules/news_room/templates/top_menu_view',
    className: 'row'
  });
});
