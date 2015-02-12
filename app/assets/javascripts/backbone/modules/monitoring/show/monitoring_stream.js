Robin.module('Monitoring.Show', function(Show, App, Backbone, Marionette, $, _){

  Show.MonitoringStream = Backbone.Marionette.ItemView.extend({
    template: 'modules/monitoring/show/templates/monitoring_stream'
  });

});