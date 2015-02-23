Robin.module("Releases", function(Releases, Robin, Backbone, Marionette, $, _){

  this.startWithParent = false;

  Releases.on("start", function(){
    this.layout = new this.Layout();
    this.controller = new this.Controller();
    this.collection = new Robin.Collections.Releases();
    this.top_menu_view = new this.TopMenuView();

    $('#nav-releases').parent().addClass('active');
  });

  Releases.on("stop", function(){
    this.layout.destroy();
    this.controller.destroy();
    this.top_menu_view.destroy();
  });

});