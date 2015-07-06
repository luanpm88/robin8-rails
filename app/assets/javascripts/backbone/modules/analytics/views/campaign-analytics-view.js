Robin.module('Analytics', function(Analytics, App, Backbone, Marionette, $, _){
  Analytics.CampaignAnalyticsPage = Backbone.Marionette.ItemView.extend({
    template: 'modules/analytics/templates/campaign-analytics',

    renderCampaignAnalytics: function() {
      $( document ).ready(function() {
        $('.tablesorter').tablesorter({
          headers : {
            0: { sorter: false },
            1: { sorter: false },
            2: { sorter: false },
            3: { sorter: "digit" },
            4: { sorter: "digit" },
            5: { sorter: "digit" },
            6: { sorter: "date" }
          }
        });
      });
      Analytics.layout.$el.find('.campaigns-label').tab('show');
    }
  });
});
