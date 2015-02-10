
var Robin = new Backbone.Marionette.Application();
Robin.Views = {};
Robin.Views.Layouts = {};
Robin.Collections = {};
Robin.Models = {};
Robin.Routers = {};

Robin.layouts = {};

Robin.addRegions({
  main: '#main'
});

Robin.navigate = function(route, options){
  options || (options = {});
  Backbone.history.navigate(route, options);
};

Robin.setIdentities = function(data){
  Robin.identities = {}
  Robin.identities.twitter = _.where(data, {provider: "twitter"})[0];
  Robin.identities.facebook = _.where(data, {provider: "facebook"})[0];
  Robin.identities.google = _.where(data, {provider: "google_oauth2"})[0];
  Robin.identities.linkedin = _.where(data, {provider: "linkedin"})[0];
};

Robin.on('start', function(){
  if (Backbone.history && !Backbone.History.started){
    Robin.addInitializer();
    Backbone.history.start();
  }
});

Robin.addInitializer(function(options){
  if (Robin.currentUser) {
    Robin.module('Navigation').start();
    Robin.module('SaySomething').start();
  } else {
    Robin.module('Authentication').start();
  }
});

Robin.vent.on("authentication:logged_in", function() {
  Robin.layouts.main = new Robin.Views.Layouts.Main();
  Robin.main.show(Robin.layouts.main);
  Robin.module('Navigation').start();
  Robin.module('SaySomething').start();
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

Robin.vent.on('SaySomething:close', function(){
  console.log('SaySomething:close triggered');
})

//Uploadcare params:
UPLOADCARE_PUBLIC_KEY = "demopublickey";
UPLOADCARE_AUTOSTORE = true;
//The UPLOADCARE_PUBLIC_KEY should be changed as soon as paid
// account is avaialble. example:
//UPLOADCARE_PUBLIC_KEY = "a51f0572e52df821db41";