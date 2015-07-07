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

    },

    wechat: function(){
      var collection = new Robin.Collections.WechatAnalytics([{"id":1, "author_first_name":"Giacomo", "author_last_name":"Guilizzoni", "email":"j@mail.com", "followers":44354, "landing_page_clicks":1555, "page_views":123, "shares":18, "kpi":"55%"}, {"id":2, "author_first_name":"Alfred", "author_last_name":"Kingston", "email":"j@mail.com", "followers":44354, "landing_page_clicks":1555, "page_views":989, "shares":65, "kpi":"54%"}, {"id":3, "author_first_name":"Gordan", "author_last_name":"Michel", "email":"g@mail.com", "followers":44354, "landing_page_clicks":1555, "page_views":554, "shares":12, "kpi":"45%"}, {"id":4, "author_first_name":"Dan", "author_last_name":"Jhons", "email":"j@mail.com", "followers":34544, "landing_page_clicks":1200, "page_views":114, "shares":12, "kpi":"44%"}, {"id":5, "author_first_name":"Tom", "author_last_name":"Hawk", "email":"j@mail.com", "followers":34544, "landing_page_clicks":1200, "page_views":111, "shares":4, "kpi":"43%"}, {"id":6, "author_first_name":"Jhon", "author_last_name":"Volker", "email":"j@mail.com", "followers":22354, "landing_page_clicks":11334, "page_views":101, "shares":18, "kpi":"38%"}]
      );

      var module = this.module;
      Robin.layouts.main.content.show(module.layout);
      var weChatAnalyticsPageView = new Analytics.WeChatAnalyticsPage({
        collection: collection
      });
      module.layout.weChatAnalyticsRegion.show(weChatAnalyticsPageView);
     },

     weibo: function(){
      var collection = new Robin.Collections.WeiboAnalytics([{"id":1, "author_first_name":"Giacomo", "author_last_name":"Guilizzoni", "email":"j@mail.com", "followers":44354, "landing_page_clicks":1555, "page_views":123, "shares":18, "kpi":"55%"}, {"id":2, "author_first_name":"Alfred", "author_last_name":"Kingston", "email":"j@mail.com", "followers":44354, "landing_page_clicks":1555, "page_views":989, "shares":65, "kpi":"54%"}, {"id":3, "author_first_name":"Gordan", "author_last_name":"Michel", "email":"g@mail.com", "followers":44354, "landing_page_clicks":1555, "page_views":554, "shares":12, "kpi":"45%"}, {"id":4, "author_first_name":"Dan", "author_last_name":"Jhons", "email":"j@mail.com", "followers":34544, "landing_page_clicks":1200, "page_views":114, "shares":12, "kpi":"44%"}, {"id":5, "author_first_name":"Tom", "author_last_name":"Hawk", "email":"j@mail.com", "followers":34544, "landing_page_clicks":1200, "page_views":111, "shares":4, "kpi":"43%"}, {"id":6, "author_first_name":"Jhon", "author_last_name":"Volker", "email":"j@mail.com", "followers":22354, "landing_page_clicks":11334, "page_views":101, "shares":18, "kpi":"38%"}]
      );
      var module = this.module;
      Robin.layouts.main.content.show(module.layout);
      var weiboAnalyticsPageView = new Analytics.WeiboAnalyticsPage({
        collection: collection
      });
      module.layout.weiboAnalyticsRegion.show(weiboAnalyticsPageView);
     }

  });
});
