var Robin = new Backbone.Marionette.Application();
Robin.Views = {};
Robin.Views.Layouts = {};
Robin.Collections = {};
Robin.Models = {};
Robin.Routers = {};

Robin.layouts = {};

Robin.addRegions({
  main: '#main',
  navigationRegion: '#navigationRegion'
});

Robin.on('start', function(){
  Backbone.history.start();
});

Robin.addInitializer(function(options){
  if (Robin.currentUser) {
    Robin.module('Navigation').start();
    console.log('Navigation is started because of currentUser is true.');
  } else {
    console.log('Navigation is NOT started because of currentUser is false.');
  }
  new Robin.Routers.Main();
});

Robin.vent.on("authentication:logged_in", function() {
  Robin.layouts.main = new Robin.Views.Layouts.Main();
  Robin.main.show(Robin.layouts.main);
});

Robin.vent.on("authentication:logged_out", function() {
  Robin.layouts.unauthenticated = new Robin.Views.Layouts.Unauthenticated();
  Robin.main.show(Robin.layouts.unauthenticated);
});

Robin.bind("before:start", function() {
  if(Robin.currentUser) {
    Robin.vent.trigger("authentication:logged_in");
  }
  else {
    Robin.vent.trigger("authentication:logged_out");
  }
});
