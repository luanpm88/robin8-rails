Robin.module('Analytics.Show', function(Show, App, Backbone, Marionette, $, _){

  Show.Controller = {

    showAnalyticsPage: function(){
      var analyticsPageView = this.getAnalyticsPageView();
      Robin.layouts.main.content.show(analyticsPageView);
    },

    getAnalyticsPageView: function(){
       return new Show.AnalyticsPage();
    },
  }

});