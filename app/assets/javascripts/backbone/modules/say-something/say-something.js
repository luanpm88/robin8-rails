Robin.module("SaySomething", function(SaySomething, Robin, Backbone, Marionette, $, _){

  this.startWithParent = false;

  var API = {

  }

  SaySomething.on('start', function(){
    console.log('SaySomething module is initialized');
  })
  
});