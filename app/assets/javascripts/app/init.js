window.Robin = new Backbone.Marionette.Application();
Robin.Views = {};
Robin.Models = {};
Robin.Routers = {};

Robin.addInitializer(function(options){
  new Robin.Routers.Main();
  Backbone.history.start();
});

$(document).ready(function() {
  Robin.start();
});

$(document).on('page:load', function() {
  Backbone.history.stop();
  Robin.start();
});

window.gplus_signin_button_callback = function( authResult ) {
  console.log(authResult);
}