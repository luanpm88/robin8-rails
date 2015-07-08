Robin.module('Analytics', function(Analytics, App, Backbone, Marionette, $, _){
  Analytics.WeChatAnalyticsPage = Backbone.Marionette.ItemView.extend({
    template: 'modules/analytics/templates/wechat-analytics',

    renderWechatAnalytics: function() {
      $( document ).ready(function() {
        $('#wechat_table').DataTable({
          "info": false,
          "searching": false,
          "lengthChange": false,
          "pageLength": 10
        });
      });
      Analytics.layout.$el.find('.wechat-label').tab('show');
    }
  });
});
