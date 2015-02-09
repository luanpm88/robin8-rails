Robin.module("SaySomething", function(SaySomething, Robin, Backbone, Marionette, $, _){

  this.startWithParent = false;

  var API = {
    showSaySomething: function() {
      SaySomething.Say.Controller.showSayView();
    }
  }

  SaySomething.on('start', function(){
    API.showSaySomething()
  })
  
});