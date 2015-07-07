Robin.module('Analytics', function(Analytics, App, Backbone, Marionette, $, _){
  Analytics.WeChatAnalyticsPage = Backbone.Marionette.ItemView.extend({
    template: 'modules/analytics/templates/wechat-analytics',

    renderWechatAnalytics: function() {
      $( document ).ready(function() {
        $('.tablesorter').tablesorter({
          headers : {
            0: { sorter: false },
            1: { sorter: false },
            2: { sorter: false },
            3: { sorter: "digit" },
            4: { sorter: "digit" },
            5: { sorter: "digit" },
            6: { sorter: "digit" },
            7: { sorter: "digit" }
          }
        });
      });
      Analytics.layout.$el.find('.wechat-label').tab('show');
    }
  });
});
