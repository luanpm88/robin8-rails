Robin.module('Analytics', function(Analytics, App, Backbone, Marionette, $, _){
  
  Analytics.Controller = Marionette.Controller.extend({
    initialize: function () {
      this.module = Robin.module("Analytics");
    },
    index: function(){
      var analyticsPageView = new Analytics.AnalyticsPage({
        collection: new Robin.Collections.NewsRooms()
      });
      var selectView;
      var module = this.module;
      Robin.layouts.main.content.show(module.layout);
      module.collection.fetch({
        success: function() {
          selectView = new Analytics.AnalyticsFilterCollectionView({
            collection: module.collection,
            childView: Analytics.AnalyticsFilterItemView
          });
          module.layout.selectRegion.show(selectView);
        }
      });
      module.layout.analyticsRegion.show(analyticsPageView);
      analyticsPageView.renderAnalytics();
    }
  });
});