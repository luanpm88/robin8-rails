Robin.module('NewsRoomPublic', function(NewsRoomPublic, App, Backbone, Marionette, $, _){

  NewsRoomPublic.SidebarView = Marionette.ItemView.extend({
    template: 'modules/news-room-public/templates/sidebar',

    events: {
      'click #twitter-timeline': 'loadTwitterWidget'
    },

    loadTwitterWidget: function (){
      if (this.model.attributes.twitter_link != null && this.model.attributes.twitter_link != '') {
        twttr.widgets.load();
      }
    }
  });
});
