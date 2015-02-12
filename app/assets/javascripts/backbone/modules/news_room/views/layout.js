// NewsRoomsLayout
Robin.module('Newsroom', function(Newsroom, App, Backbone, Marionette, $, _){

  Newsroom.Layout = Marionette.LayoutView.extend({
    template: 'modules/news_room/templates/layout',
    regions: {
      topMenuRegion: '.top_menu',
      mainContentRegion: '.main_content',
    },
    closeAllRegions: function(){
      this.regionManager.each(function(region){
        region.close();
      });
    }
  });
});

