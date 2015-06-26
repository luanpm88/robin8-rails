Robin.module("Recommendations", function(Recommendations, Robin, Backbone, Marionette, $, _){

  this.startWithParent = false;

  Recommendations.on("start", function(){
    $('#nav-recommendations').parent().addClass('active');
     this.layout = new this.Layout();
     this.controller = new this.Controller();
     this.controller.index("CONTENT");
  });

  Recommendations.on("stop", function(){
    this.layout.destroy();
    this.controller.destroy();
  });
});
