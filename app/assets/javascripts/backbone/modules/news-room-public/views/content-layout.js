// NewsRoomsLayout
Robin.module('NewsRoomPublic', function(Newsroom, App, Backbone, Marionette, $, _){

  Newsroom.ContentLayout = Marionette.LayoutView.extend({
    template: 'modules/news-room-public/templates/content-layout',
    regions: {
      contentHead: '#content-head',
      releases: '#releases',
      pagination: '#pagination',
      contentFooter: '#content-footer'
    }
  });
});

