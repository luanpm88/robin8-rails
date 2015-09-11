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
      emailsDroppedListRegion: '#emails-dropped-list-region'
    },

    events: {
      'change .change-web-news-room': 'changeWebNewsRoom',
      'change .change-emails-news-room': 'changeEmailsData',
      'change .change-emails-release' : 'changeEmailsData',
      'click .emails-label': 'navigateToEmails',
      'click .web-label': 'navigateToWeb'
    },

    changeWebNewsRoom: function(event) {
      var webAnalyticsPageView = new Analytics.WebAnalyticsPage({
        collection: new Robin.Collections.NewsRooms()
      });
      
      this.webAnalyticsRegion.show(webAnalyticsPageView);
      webAnalyticsPageView.renderAnalytics($(event.target).val());
    },

    changeEmailsData: function(event) {
      var $this = this;
      var params = '';
      var emailsAnalyticsPageView;
      var release = false;

      if ($(event.target).hasClass('change-emails-release')) {
        params = '?type=release';
        release = true;
        emailsAnalyticsPageView = new Analytics.EmailsAnalyticsPage({
          collection: new Robin.Collections.Releases()
        });
      } else {
        emailsAnalyticsPageView = new Analytics.EmailsAnalyticsPage({
          collection: new Robin.Collections.NewsRooms()
        });
      }

      $this.emailsAnalyticsRegion.show(emailsAnalyticsPageView);

      if (release) {
        emailsAnalyticsPageView.renderEmailAnalytics($(event.target).val(), 'release');
      } else {
        emailsAnalyticsPageView.renderEmailAnalytics($(event.target).val());
      }

      var collectionEmails = new Robin.Collections.EmailAnalytics();
      collectionEmails.fetch({
        url: '/news_rooms/' + $(event.target).val() +'/email_analytics' + params,

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
    }

  });

});