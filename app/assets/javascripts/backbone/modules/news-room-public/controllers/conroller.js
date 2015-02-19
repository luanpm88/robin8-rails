Robin.module('NewsRoomPublic', function(NewsRoomPublic, App, Backbone, Marionette, $, _){

  NewsRoomPublic.Controller = Marionette.Controller.extend({
    initialize: function () {
      this.module = Robin.module("NewsRoomPublic");
    },
    index: function(){
      Robin.layouts.main.getRegion('content').show(this.module.layout);
      var sidebarView = new this.module.SidebarView();
      var newsRoomView = new this.module.NewsRoomView();
      this.module.layout.sidebar.show(sidebarView);
      this.module.layout.content.show(newsRoomView);
    }
  });
});