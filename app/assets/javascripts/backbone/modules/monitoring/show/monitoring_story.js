Robin.module('Monitoring.Show', function(Show, App, Backbone, Marionette, $, _){

  Show.MonitoringStory = Backbone.Marionette.ItemView.extend({
    template: 'modules/monitoring/show/templates/monitoring_story'
  });

});
