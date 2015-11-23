Robin.module("CnRecommendations", function(CnRecommendations, Robin, Backbone, Marionette, $, _){
  this.startWithParent = false;
  
  CnRecommendations.on("start", function(){
    this.layout = new CnRecommendations.Layout();
    this.controller = new CnRecommendations.Controller()
    this.controller.index();
    console.log("start cn recommendations");
  });

  CnRecommendations.on("stop", function(){
    this.layout.destroy();
    this.controller.destroy();
  });

});