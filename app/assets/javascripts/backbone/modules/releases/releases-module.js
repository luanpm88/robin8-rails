Robin.module("Releases", function(Releases, Robin, Backbone, Marionette, $, _){

  this.startWithParent = false;

  Releases.on("start", function(){
    this.layout = new this.Layout();
    this.top_menu_view = new this.TopMenuView();
    this.controller = new this.Controller();
    this.collection = new Robin.Collections.Releases();
    $('#nav-releases').parent().addClass('active');
    this.router = new this.Router({controller: this.controller});
    Backbone.history.loadUrl(Backbone.history.fragment);
  });

  Releases.on("stop", function(){
    this.layout.destroy();
    this.controller.destroy();
    this.top_menu_view.destroy();
  });

});