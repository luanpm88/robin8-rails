Robin.Routers.AppRouter = Backbone.Marionette.AppRouter.extend({
  appRoutes: {
    'dashboard(/*path)': 'showDashboard',
    'robin8(/*path)': 'showRobin',
    'news_rooms(/*path)': "showNewsRooms",
    'releases(/*path)': "showReleases",
    'social(/*path)': "showSocial",
    'analytics(/*path)': "showAnalytics",
    'profile(/*path)': "showProfile",
  },
  initialize: function(options){
    Robin.routesCount = _.size(this.appRoutes);
  }
});