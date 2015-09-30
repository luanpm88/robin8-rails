Robin.module('Analytics', function(Analytics, App, Backbone, Marionette, $, _){
  Analytics.CampaignAnalyticsPage = Backbone.Marionette.ItemView.extend({
    template: 'modules/analytics/templates/campaign-analytics',

    renderCampaignAnalytics: function() {
      $( document ).ready(function() {
        $('.an-campaigns-table').DataTable({
          "info": false,
          "searching": false,
          "lengthChange": false,
          "pageLength": 10
        });
      });
      Analytics.layout.$el.find('.campaigns-label').tab('show');
    }
  });
});
