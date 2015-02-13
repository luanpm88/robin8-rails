Robin.module('Dashboard.Show', function(Show, App, Backbone, Marionette, $, _){

  Show.Controller = {

    showDashboardPage: function(){
      var socialPageView = this.getDashboardPageView();
      Robin.layouts.main.content.show(socialPageView);
    },

    getDashboardPageView: function(){
      return new Show.DashboardPage();
    },
  }

});