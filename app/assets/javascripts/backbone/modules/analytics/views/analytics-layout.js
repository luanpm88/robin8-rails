Robin.module('Analytics', function(Analytics, App, Backbone, Marionette, $, _){
  Analytics.Layout = Backbone.Marionette.LayoutView.extend({
    template: 'modules/analytics/templates/layout',

    regions: {
      selectWebRegion: '#select-web-region',
      selectEmailRegion: '#select-email-region',
      webAnalyticsRegion: '#analytics-region',
      emailsAnalyticsRegion: '#emails-analytics-region',
      emailsListRegion: '#emails-list-region',
      weChatAnalyticsRegion: '#wechat-analytics-region',
      weiboAnalyticsRegion: '#weibo-analytics-region',
      campaignAnalyticsRegion: '#campaign-analytics-region'
    },

    events: {
      'change .change-web-news-room': 'changeWebNewsRoom',
      'change .change-emails-news-room': 'changeEmailsNewsRoom',
      'click .emails-label': 'navigateToEmails',
      'click .web-label': 'navigateToWeb',
      'click .wechat-label': 'navigateToWeChatReport',
      'click .weibo-label': 'navigateToWeiboReport',
      'click .campaigns-label': 'navigateToCampaign'
    },

    changeWebNewsRoom: function(event) {
      var webAnalyticsPageView = new Analytics.WebAnalyticsPage({
        collection: new Robin.Collections.NewsRooms()
      });

      this.webAnalyticsRegion.show(webAnalyticsPageView);
      webAnalyticsPageView.renderAnalytics($(event.target).val());
    },

    changeEmailsNewsRoom: function(event) {
      var $this = this;
      var emailsAnalyticsPageView = new Analytics.EmailsAnalyticsPage({
        collection: new Robin.Collections.NewsRooms()
      });

      $this.emailsAnalyticsRegion.show(emailsAnalyticsPageView);
      emailsAnalyticsPageView.renderEmailAnalytics($(event.target).val());

      var collectionEmails = new Robin.Collections.EmailAnalytics()
      collectionEmails.fetch({
        url: '/news_rooms/' + $(event.target).val() +'/email_analytics',
        success: function(collection, data, response){
          var collection = new Robin.Collections.EmailAnalytics(data.authors);
          var emailListView = new Analytics.EmailsListCompositeView({
            collection: collection
          });
          $this.emailsListRegion.show(emailListView);
        }
      })
    },

    navigateToEmails: function(){
      Backbone.history.navigate('analytics-email', {trigger:true});
    },

    navigateToWeb: function(){
      Backbone.history.navigate('analytics', {trigger:true});
    },

    navigateToWeChatReport: function(){
      Backbone.history.navigate('analytics-wechat', {trigger:true});
    },

    navigateToWeiboReport: function(){
      Backbone.history.navigate('analytics-weibo', {trigger:true});
    },

    navigateToCampaign: function(){
      Backbone.history.navigate('analytics-campaign', {trigger:true});
    }

  });

});
