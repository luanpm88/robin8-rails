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
      var releasesCompositeView = new module.ReleasesCompositeView({
        collection: releases,
        childView: module.ReleaseView
      });

      module.contentLayout = new module.ContentLayout();

      this.filterCriteria = {
        page: 1,
        per_page:3
      };
      var contrObj = this;

      newsRoom.preview().done(function(data){
        module.layout.sidebar.show(sidebarView);
        module.layout.content.show(module.contentLayout);
        module.contentLayout.contentHead.show(contentHeadView);
        module.contentLayout.contentFooter.show(contentFooterView);

        releases.filter({
          params: contrObj.filterCriteria,
          success: function(collection, data, response){

            module.paginationView = new module.PaginationView({
              model: new Robin.Models.Pagination ({
                page: contrObj.filterCriteria.page,
                per_page: contrObj.filterCriteria.per_page,
                total_count: parseInt(response.xhr.getResponseHeader('Totalcount'),10),
                total_pages: parseInt(response.xhr.getResponseHeader('Totalpages'),10)
              })
            });

            contrObj.renderCollectionView(collection, response);
            if(collection.length)
              module.contentLayout.pagination.show(module.paginationView);
          }
        })

      });

    },

    paginate: function(page){
      var contrObj = this;
      this.filterCriteria.page = page;
      var releaseCollection = new Robin.Collections.Releases();
      releaseCollection.filter({
        params: contrObj.filterCriteria,
        success: function(collection, data, response){
          contrObj.renderCollectionView(collection, response);
          contrObj.module.pagination_view.model.set({
            page: page,
            per_page: contrObj.filterCriteria.per_page,
            total_count: parseInt(response.xhr.getResponseHeader('Totalcount'),10),
            total_pages: parseInt(response.xhr.getResponseHeader('Totalpages'),10)
          });
          $("html, body").animate({ scrollTop: $(document).height() }, 1000);
        }
      })
    },

    presskit: function() {
      var module = this.module;
      var newsRoom = new Robin.Models.NewsRoom();
      var presskitView = new module.PresskitView({ model: newsRoom });
      newsRoom.preview().done(function(data){
        module.layout.content.show(presskitView);
      });
    },

    renderCollectionView: function (collection, response){
      var view = new this.module.ReleasesCompositeView({
        collection:  collection,
        childView: this.module.ReleaseView
      });
      this.module.contentLayout.releases.show(view);
    }

  });
});