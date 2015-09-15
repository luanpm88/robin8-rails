Robin.module('Analytics', function(Analytics, App, Backbone, Marionette, $, _){
  Analytics.Layout = Backbone.Marionette.LayoutView.extend({
    template: 'modules/analytics/templates/layout',

    regions: {
      selectWebRegion: '#select-web-region',
      selectEmailRegion: '#select-email-region',
      selectReleaseRegion: '#select-release-region',
      webAnalyticsRegion: '#analytics-region',
      emailsAnalyticsRegion: '#emails-analytics-region',
      emailsListRegion: '#emails-list-region',
      weChatAnalyticsRegion: '#wechat-analytics-region',
      weiboAnalyticsRegion: '#weibo-analytics-region',
      campaignAnalyticsRegion: '#campaign-analytics-region',
      emailsDroppedListRegion: '#emails-dropped-list-region'
    },

    events: {
      'change .change-web-news-room': 'changeWebNewsRoom',
      'change .change-emails-news-room': 'changeEmailsData',
      'click #apply-date': 'changeDateRange',
      'change .change-emails-release' : 'changeEmailsData',
      'click #apply-email-date': 'changeEmailsData',
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

    changeDateRange: function(event) {
      var webAnalyticsPageView = new Analytics.WebAnalyticsPage({
        collection: new Robin.Collections.NewsRooms()
      });

      this.webAnalyticsRegion.show(webAnalyticsPageView);
      webAnalyticsPageView.renderAnalytics();
    },

    changeEmailsData: function(event) {
      var $this = this;
      var params = '';
      var emailsAnalyticsPageView;
      var release = false;
      var target = $(event.target);
      var itemId = target.val();

      if (target.hasClass('change-emails-release') && itemId != 0) {
        params = '?type=release';
        release = true;
        emailsAnalyticsPageView = new Analytics.EmailsAnalyticsPage({
          collection: new Robin.Collections.Releases()
        });
      } else {
        if (itemId != 0) {
          var collectionReleases = new Robin.Collections.Releases();
          collectionReleases.fetchReleasesForBrandGallery({
            brandGalleryId: itemId,
            success: function(collection) {
              selectReleasesView = new Analytics.EmailsFilterReleasesCollectionView({
                collection: collection,
                childView: Analytics.EmailsFilterReleaseItemView
              });

              $this.selectReleaseRegion.show(selectReleasesView);
            }
          });
        } else {
          itemId = $('.change-emails-news-room').val();
        }

        emailsAnalyticsPageView = new Analytics.EmailsAnalyticsPage({
          collection: new Robin.Collections.NewsRooms()
        });
      }

      $this.emailsAnalyticsRegion.show(emailsAnalyticsPageView);

      if (release) {
        emailsAnalyticsPageView.renderEmailAnalytics(itemId, 'release');
      } else {
        emailsAnalyticsPageView.renderEmailAnalytics(itemId);
      }

      var collectionEmails = new Robin.Collections.EmailAnalytics();
      collectionEmails.fetch({
        url: '/news_rooms/' + itemId +'/email_analytics' + params,

        success: function(collection, data, response){
          var collection = new Robin.Collections.EmailAnalytics(data.authors);
          var collection_dropped = new Robin.Collections.EmailAnalytics(data.authors_dropped);
          var emailListView = new Analytics.EmailsListCompositeView({
            collection: collection
          });
          var emailDroppedListView = new Analytics.EmailsDroppedListCompositeView({
            collection: collection_dropped
          });
          $this.emailsListRegion.show(emailListView);
          $this.emailsDroppedListRegion.show(emailDroppedListView);
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
