Robin.module("Newsroom", function(Newsroom, Robin, Backbone, Marionette, $, _){

  this.startWithParent = false;

  Newsroom.on("start", function(){
    this.layout = new this.Layout();
    this.controller = new this.Controller();
    this.collection = new Robin.Collections.NewsRooms();
  });

  Newsroom.on("stop", function(){
    this.layout.destroy();
    this.controller.destroy();
  });
});
