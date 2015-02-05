Robin.module('SaySomething.Say', function(Say, App, Backbone, Marionette, $, _){

  Say.Controller = {

    showSayView: function(){
    },

    getSayView: function(){
      return new Say.SayView();
    }

  }

});