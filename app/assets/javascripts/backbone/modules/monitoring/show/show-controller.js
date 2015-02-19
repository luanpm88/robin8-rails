Robin.module('Monitoring.Show', function(Show, App, Backbone, Marionette, $, _){

  Show.Controller = {

    showMonitoringPage: function(){
      this.layout = new Show.LayoutView();
      Robin.layouts.main.content.show(this.layout);
    }
  }

});