Robin.Routers.AppRouter = Backbone.Marionette.AppRouter.extend({
  appRoutes: {
    '': 'showDashboard',
    'dashboard(/*path)': 'showDashboard',
    'robin8(/*path)': 'showRobin',
    'monitoring(/*path)': 'showMonitoring',
    'news_rooms(/*path)': "showNewsRooms",
    'releases(/*path)': "showReleases",
    'social(/*path)': "showSocial",
    // 'analytics(/*path)': "showAnalytics",
    'profile(/*path)': "showProfile",
    'billing(/*path)': "showBilling",
  },
  initialize: function(options){
    Robin.routesCount = _.size(this.appRoutes);
  }
});