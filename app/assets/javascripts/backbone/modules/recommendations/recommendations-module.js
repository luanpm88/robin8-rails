Robin.module("Recommendations", function(Recommendations, Robin, Backbone, Marionette, $, _){

  this.startWithParent = false;

  Recommendations.on("start", function(){
    this.controller = new this.Controller();
    this.router = new this.Router({controller: this.controller});
    $('#nav-recommendations').parent().addClass('active');
    Backbone.history.loadUrl(Backbone.history.fragment);
  });

  Recommendations.on("stop", function(){
    this.controller.destroy();
  });
});
