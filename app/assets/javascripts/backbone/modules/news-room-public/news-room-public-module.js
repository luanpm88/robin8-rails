Robin.module("NewsRoomPublic", function(NewsRoomPublic, Robin, Backbone, Marionette, $, _){

  this.startWithParent = false;

  NewsRoomPublic.on("start", function(){
    this.layout = new this.Layout();
    // Robin.layouts.main.getRegion('content').show(this.layout);
    this.controller = new this.Controller();
    // this.collection = new Robin.Collections.NewsRooms();
  });

  NewsRoomPublic.on("stop", function(){
    // this.layout.destroy();
    // this.controller.destroy();
  });
});
