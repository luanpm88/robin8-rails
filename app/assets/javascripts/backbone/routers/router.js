Robin.Routers.AppRouter = Backbone.Marionette.AppRouter.extend({
  appRoutes: {
    '': 'showDashboard',
    'dashboard(/*path)': 'showDashboard',
    'robin8(/*path)': 'showRobin',
    'smart_campaign(/*path)': 'showSmartCampaign',
    'manage_users(/*path)': "showManageUsers",
    'monitoring(/*path)': 'showMonitoring',
    'news_rooms(/*path)': "showNewsRooms",
    'releases(/*path)': "showReleases",
    'social(/*path)': "showSocial",
    'analytics(/*path)': "showAnalytics",
    'analytics-email(/*path)': 'showEmailsAnalytics',
    'analytics-campaign(/*path)': 'showCampaignAnalytics',
    'profile(/*path)': "showProfile",
    'billing(/*path)': "showBilling",
    'recommendations(/*path)': "showRecommendations",
    'campaigns(/*path)': 'showCampaigns',
    'analytics-wechat(/*path)': 'showWeChatAnalytics',
    'analytics-weibo(/*path)': 'showWeiboAnalytics',
    'campaigns_list(/*path)': "showCampaignsList",
    'cn-recommendations(/*path)': "showCnRecommendations",
    // 'transactions(/*path)': "showTransactions",
  },
  initialize: function(options){
    Robin.routesCount = _.size(this.appRoutes);
  }
});
