Robin.module('Monitoring.Show', function(Show, App, Backbone, Marionette, $, _){

  Show.Controller = {

    showMonitoringPage: function(){
      var socialPageView = this.getMonitoringPageView();
      Robin.layouts.main.content.show(socialPageView);
    },

    getMonitoringPageView: function(){
      return new Show.MonitoringPage();
    },
  }

});