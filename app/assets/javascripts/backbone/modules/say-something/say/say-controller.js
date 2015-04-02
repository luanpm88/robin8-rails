Robin.module('SaySomething.Say', function(Say, App, Backbone, Marionette, $, _){

  Say.Controller = {

    showSayView: function(){
      if (Robin.identities == undefined) {
        $.get( "/users/identities", function( data ) {
          Robin.setIdentities(data);        
          
          Robin.sayView = new Say.SayView();
          Robin.layouts.main.saySomething.show(Robin.sayView);
        });
      } else {
        Robin.sayView = new Say.SayView();
        Robin.layouts.main.saySomething.show(Robin.sayView);
      } 
    },

    getSayView: function(){
      return new Say.SayView();
    }

  }

});