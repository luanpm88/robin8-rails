Robin.module('NewsRoomPublic', function(NewsRoomPublic, App, Backbone, Marionette, $, _){

  NewsRoomPublic.Controller = Marionette.Controller.extend({

    initialize: function () {
      this.module = Robin.module("NewsRoomPublic");
    },

    index: function(){
      var module = this.module;
      Robin.layouts.main.getRegion('content').show(module.layout);
      var newsRoom = new Robin.Models.NewsRoom();
      var sidebarView = new module.SidebarView({ model: newsRoom });
      var newsRoomView = new module.NewsRoomView({ model: newsRoom });
      newsRoom.preview().done(function(data){
        module.layout.sidebar.show(sidebarView);
        module.layout.content.show(newsRoomView);
      });
    },

    presskit: function() {
      console.log('presskit');
      var module = this.module;
      var newsRoom = new Robin.Models.NewsRoom();
      var presskitView = new module.PresskitView({ model: newsRoom });
      newsRoom.preview().done(function(data){
        module.layout.content.show(presskitView);
      });
    }

  });
});