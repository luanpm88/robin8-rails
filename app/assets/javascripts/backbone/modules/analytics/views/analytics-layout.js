Robin.module('Analytics', function(Analytics, App, Backbone, Marionette, $, _){
  Analytics.Layout = Backbone.Marionette.LayoutView.extend({
    template: 'modules/analytics/templates/layout',

    regions: {
      selectRegion: '#select-region',
      analyticsRegion: '#analytics-region'
    },

    events: {
      'change .change-news-room': 'changeNewsRoom'
    },

    changeNewsRoom: function(event) {
      console.log('here!!!');
      var analyticsPageView = new Analytics.AnalyticsPage({
        collection: new Robin.Collections.NewsRooms()
      });
      
      this.analyticsRegion.show(analyticsPageView);
      analyticsPageView.renderAnalytics($(event.target).val());
      // this.renderAnalytics($(event.target).val());
    },

  });
  

});