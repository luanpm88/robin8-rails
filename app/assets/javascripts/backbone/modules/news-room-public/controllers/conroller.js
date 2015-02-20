Robin.module('NewsRoomPublic', function(NewsRoomPublic, App, Backbone, Marionette, $, _){

  NewsRoomPublic.Controller = Marionette.Controller.extend({

    initialize: function () {
      this.module = Robin.module("NewsRoomPublic");
    },

    index: function(){
      var module = this.module;
      Robin.layouts.main.getRegion('content').show(module.layout);
      var newsRoom = new Robin.Models.NewsRoom();
      var releases = new Robin.Collections.Releases();

      var sidebarView = new module.SidebarView({ model: newsRoom });
      var contentHeadView = new module.ContentHeadView({ model: newsRoom });
      var contentFooterView = new module.ContentFooterView({ model: newsRoom });
      var releasesCompositeView = new module.ReleasesCompositeView({ collection: releases });
      var releasesCompositeView = new module.ReleasesCompositeView({
        collection: releases,
        childView: module.ReleaseView
      });

      module.contentLayout = new module.ContentLayout();

      newsRoom.preview().done(function(data){
        module.layout.sidebar.show(sidebarView);
        module.layout.content.show(module.contentLayout);
        module.contentLayout.contentHead.show(contentHeadView);
        module.contentLayout.contentFooter.show(contentFooterView);
        releases.filter({ params: { by_news_room: 4 },
          success: function(collection, data, response){
            module.contentLayout.releases.show(releasesCompositeView);
          }
        });

      });

    },

    presskit: function() {
      var module = this.module;
      var newsRoom = new Robin.Models.NewsRoom();
      var presskitView = new module.PresskitView({ model: newsRoom });
      newsRoom.preview().done(function(data){
        module.layout.content.show(presskitView);
      });
    }

  });
});