Robin.module('Social.Show', function(Show, App, Backbone, Marionette, $, _){

  Show.Controller = {

    showSocialPage: function(){
      var socialPageView = this.getSocialPageView();
      Robin.layouts.main.content.show(socialPageView);
    },

    getSocialPageView: function(){
      return new Show.SocialPage();
    },
  }

});