Robin.module("Navigation", function(Navigation, Robin, Backbone, Marionette, $, _){

  this.startWithParent = false;

  var API = {
    showNavigation: function() {
      Navigation.Show.Controller.showNavigation();
    }
  }

  Navigation.on('start', function(){
    API.showNavigation();
  })
  
});