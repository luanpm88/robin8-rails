Robin.module('Releases.Show', function(Show, App, Backbone, Marionette, $, _){

  Show.Controller = {

    showReleasesPage: function(){
      var releasesPageView = this.getReleasesPageView();
      Robin.layouts.main.content.show(releasesPageView);
    },

    getReleasesPageView: function(){
      return new Show.ReleasesPage();
    },
  }

});