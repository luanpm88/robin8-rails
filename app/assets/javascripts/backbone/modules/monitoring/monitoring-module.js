Robin.module("Monitoring", function(Monitoring, Robin, Backbone, Marionette, $, _){

  this.startWithParent = false;

  var API = {
    showMonitoringPage: function() {
      Monitoring.Show.Controller.showMonitoringPage();
    }
  }

  Monitoring.on('start', function(){
    API.showMonitoringPage();
    $('#sidebar li.active').removeClass('active');
    $('#nav-monitoring').parent().addClass('active');
  });

  Monitoring.on("stop", function(){
    this.Show.Controller.layout.destroy();
  });
});