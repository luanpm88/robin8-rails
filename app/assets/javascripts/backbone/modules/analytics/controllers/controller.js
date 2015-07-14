Robin.module('Analytics', function(Analytics, App, Backbone, Marionette, $, _){
  
  Analytics.Controller = Marionette.Controller.extend({

    initialize: function () {
      this.module = Robin.module("Analytics");
    },

    index: function(){
      var webAnalyticsPageView = new Analytics.WebAnalyticsPage({
        collection: new Robin.Collections.NewsRooms()
      });
      var selectView;
      var module = this.module;
      Robin.layouts.main.content.show(module.layout);
      module.collection.fetch({
        success: function() {
          selectView = new Analytics.WebFilterCollectionView({
            collection: module.collection,
            childView: Analytics.WebFilterItemView
          });
          module.layout.selectWebRegion.show(selectView);
        }
      });
      module.layout.webAnalyticsRegion.show(webAnalyticsPageView);
      webAnalyticsPageView.renderAnalytics();
    },

    emails: function(){
      var emailsAnalyticsPageView = new Analytics.EmailsAnalyticsPage({
        collection: new Robin.Collections.NewsRooms()
      });
      var selectView;
      var module = this.module;
      Robin.layouts.main.content.show(module.layout);
      module.collection.fetch({
        success: function(collection, data, response) {
          selectView = new Analytics.EmailsFilterCollectionView({
            collection: module.collection,
            childView: Analytics.EmailsFilterItemView
          });
          var collectionNewsRooms = collection;
          module.layout.selectEmailRegion.show(selectView);
          var collectionEmails = new Robin.Collections.EmailAnalytics()
          collectionEmails.fetch({
            url: '/news_rooms/' + collectionNewsRooms.models[0].id +'/email_analytics',
            success: function(collection, data, response){
              var collection = new Robin.Collections.EmailAnalytics(data.authors);
              var emailListView = new Analytics.EmailsListCompositeView({
                collection: collection
              });
              module.layout.emailsListRegion.show(emailListView);
            }
          })
        }
      });
      

      module.layout.emailsAnalyticsRegion.show(emailsAnalyticsPageView);
      emailsAnalyticsPageView.renderEmailAnalytics();

    }

  });
});