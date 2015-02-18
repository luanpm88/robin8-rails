Robin.module('Monitoring.Show', function(Show, App, Backbone, Marionette, $, _){

  Show.Controller = {

    showMonitoringPage: function(){
      var monitoringView = this.getMonitoringPageView();
      Robin.layouts.main.content.show(monitoringView);
    },

    getMonitoringPageView: function(){
      return new Show.MonitoringPage();
    }
  }

});