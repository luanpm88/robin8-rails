Robin.module("Navigation", function(Navigation, Robin, Backbone, Marionette, $, _){

  this.startWithParent = false;

  API = {
    showNavigation: function() {
      Navigation.Show.Controller.showNavigation();
    }
  }

  Navigation.on('start', function(){
    API.showNavigation();
  })
  
});