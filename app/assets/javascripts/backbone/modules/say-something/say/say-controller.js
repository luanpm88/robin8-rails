Robin.module('SaySomething.Say', function(Say, App, Backbone, Marionette, $, _){

  Say.Controller = {

    showSayView: function(){
      var sayView = new Say.SayView();
      Robin.layouts.main.saySomething.show(sayView);
    },

    getSayView: function(){
      return new Say.SayView();
    }

  }

});