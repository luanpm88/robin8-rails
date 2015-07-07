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
      weChatAnalyticsPageView.renderWechatAnalytics();
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
      weiboAnalyticsPageView.renderWeiboAnalytics();
     },

    campaign: function(){
      var collection = new Robin.Collections.CampaignAnalytics([{"id":1, "campaign_name":"New TV release", "campaign_date_start":"01.05.15", "campaign_date_end":"02.05.15", "subcampaign": [{"subcampaign_name":"New Smartphone release", "subcampaign_date_start":"02.12.15", "subcampaign_date_end":"12.01.16", "table":[{"title":"New Smartphone comming soon!", "blog_name":"New York Post", "author_name":"Giacomo Guilizzoni", "views":123, "social_share_name":"weibo","shares":6, "likes":18, "published_at":"12.12.15"}, {"title":"Amazing New Smartphone", "blog_name":"the American Interest", "author_name":"Den Jhons", "views":114, "social_share_name":"wechat","shares":7, "likes":12, "published_at":"18.12.15"}, {"title":"iPear Smartphone overview!", "blog_name":"New York Post", "author_name":"Jhon Jhon", "views":101, "social_share_name":"weibo","shares":6, "likes":18, "published_at":"10.01.16"},{"title":"Amazing New Smartphone!", "blog_name":"the American Interest", "author_name":"Den Jhons", "views":98, "social_share_name":"weibo","shares":7, "likes":12, "published_at":"19.12.15"}]}]}, {"id":2, "campaign_name":"New Laptop release", "campaign_date_start":"03.11.15", "campaign_date_end":"04.12.15", "subcampaign": [{"subcampaign_name":"New Smartphone release", "subcampaign_date_start":"02.12.15", "subcampaign_date_end":"12.01.16", "table":[{"title":"New Smartphone comming soon!", "blog_name":"New York Post", "author_name":"Giacomo Guilizzoni", "views":123, "social_share_name":"weibo","shares":6, "likes":18, "published_at":"12.12.15"}, {"title":"Amazing New Smartphone", "blog_name":"the American Interest", "author_name":"Den Jhons", "views":114, "social_share_name":"wechat","shares":7, "likes":12, "published_at":"18.12.15"}, {"title":"iPear Smartphone overview!", "blog_name":"New York Post", "author_name":"Jhon Jhon", "views":101, "social_share_name":"weibo","shares":6, "likes":18, "published_at":"10.01.16"},{"title":"Amazing New Smartphone!", "blog_name":"the American Interest", "author_name":"Den Jhons", "views":98, "social_share_name":"weibo","shares":7, "likes":12, "published_at":"19.12.15"}]}]}, {"id":3, "campaign_name":"New TV release", "campaign_date_start":"01.05.15", "campaign_date_end":"02.05.15", "subcampaign": [{"subcampaign_name":"New Screen release", "subcampaign_date_start":"12.03.16", "subcampaign_date_end":"20.04.16", "table":[{"title":"New Smartphone comming soon!", "blog_name":"New York Post", "author_name":"Giacomo Guilizzoni", "views":123, "social_share_name":"weibo","shares":6, "likes":18, "published_at":"12.12.15"}, {"title":"Amazing New Smartphone", "blog_name":"the American Interest", "author_name":"Den Jhons", "views":114, "social_share_name":"wechat","shares":7, "likes":12, "published_at":"18.12.15"}, {"title":"iPear Smartphone overview!", "blog_name":"New York Post", "author_name":"Jhon Jhon", "views":101, "social_share_name":"weibo","shares":6, "likes":18, "published_at":"10.01.16"},{"title":"Amazing New Smartphone!", "blog_name":"the American Interest", "author_name":"Den Jhons", "views":98, "social_share_name":"weibo","shares":7, "likes":12, "published_at":"19.12.15"}]}]}]);

      var module = this.module;
      Robin.layouts.main.content.show(module.layout);
      var campaignAnalyticsPageView = new Analytics.CampaignAnalyticsPage({
        collection: collection
      });
      module.layout.campaignAnalyticsRegion.show(campaignAnalyticsPageView);
      campaignAnalyticsPageView.renderCampaignAnalytics();
    }

  });
});
