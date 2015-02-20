Robin.module("NewsRoomPublic", function(NewsRoomPublic, Robin, Backbone, Marionette, $, _){

  this.startWithParent = false;

  NewsRoomPublic.on("start", function(){
    this.layout = new this.Layout();
    this.controller = new this.Controller();
    this.router = new this.Router({controller: this.controller});
  });

  NewsRoomPublic.on("stop", function(){
    this.layout.destroy();
    this.controller.destroy();
  });
});
