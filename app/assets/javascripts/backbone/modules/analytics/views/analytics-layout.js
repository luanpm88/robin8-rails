Robin.module('Analytics', function(Analytics, App, Backbone, Marionette, $, _){
  Analytics.Layout = Backbone.Marionette.LayoutView.extend({
    template: 'modules/analytics/templates/layout',

    regions: {
      selectWebRegion: '#select-web-region',
      selectEmailRegion: '#select-email-region',
      webAnalyticsRegion: '#analytics-region',
      emailsAnalyticsRegion: '#emails-analytics-region',
      emailsListRegion: '#emails-list-region',
      emailsDroppedListRegion: '#emails-dropped-list-region'
    },

    events: {
      'change .change-web-news-room': 'changeWebNewsRoom',
      'change .change-emails-news-room': 'changeEmailsNewsRoom',
      'click #apply-date': 'changeDateRange',
      'click #apply-email-date': 'changeEmailsNewsRoom',
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

    changeDateRange: function(event) {
      var webAnalyticsPageView = new Analytics.WebAnalyticsPage({
        collection: new Robin.Collections.NewsRooms()
      });

      this.webAnalyticsRegion.show(webAnalyticsPageView);
      webAnalyticsPageView.renderAnalytics();
    },

    changeEmailsNewsRoom: function(event) {
      var event_val = $(event.target).val();
      if (event_val == false) {
        event_val = $('.change-emails-news-room').val()
      }
      var $this = this;
      var emailsAnalyticsPageView = new Analytics.EmailsAnalyticsPage({
        collection: new Robin.Collections.NewsRooms()
      });

      $this.emailsAnalyticsRegion.show(emailsAnalyticsPageView);
      emailsAnalyticsPageView.renderEmailAnalytics(event_val);

      var collectionEmails = new Robin.Collections.EmailAnalytics();

      var start = new Date($('#start-email-date-input').val());
      var end = new Date($('#end-email-date-input').val());

      collectionEmails.fetch({
        url: '/news_rooms/' + event_val +'/email_analytics/' + '?start_date=' + start + '&end_date=' + end,

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
