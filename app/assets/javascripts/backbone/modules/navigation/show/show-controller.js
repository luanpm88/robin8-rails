Robin.module('Navigation.Show', function(Show, App, Backbone, Marionette, $, _){

  Show.Controller = {

    showNavigation: function(){
      var navigationView = this.getNavigationView();
      Robin.layouts.main.sidebar.show(navigationView);
    },

    getNavigationView: function(){
      return new Show.NavigationView();
    }

  }

});