Robin.module('Analytics', function(Analytics, App, Backbone, Marionette, $, _){
  Analytics.WeiboAnalyticsPage = Backbone.Marionette.ItemView.extend({
    template: 'modules/analytics/templates/weibo-analytics',

    renderWeiboAnalytics: function() {
      $( document ).ready(function() {
        $('#weibo_table').DataTable({
          "info": false,
          "searching": false,
          "lengthChange": false,
          "pageLength": 10
        });
      });
      Analytics.layout.$el.find('.weibo-label').tab('show');
    }
  });
});
