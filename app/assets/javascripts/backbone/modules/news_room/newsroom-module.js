Robin.module("Newsroom", function(Newsroom, Robin, Backbone, Marionette, $, _){

  this.startWithParent = false;

  Newsroom.on("start", function(){
    this.layout = new this.Layout();
    this.controller = new this.Controller();
    this.router = new this.Router({controller: this.controller});
    this.collection = new Robin.Collections.NewsRooms();
    $('#nav-newsrooms').parent().addClass('active');
    Backbone.history.loadUrl(Backbone.history.fragment);
  });

  Newsroom.on("stop", function(){
    this.layout.destroy();
    this.controller.destroy();
  });
});
