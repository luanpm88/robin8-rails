Robin.module('Newsroom', function(Newsroom, App, Backbone, Marionette, $, _){

  Newsroom.Controller = Marionette.Controller.extend({
    initialize: function () {
      this.module = Robin.module("Newsroom");
    },
    index: function(){
      this.filterCriteria = {
        page: 1,
        per_page:9
      };
      var contrObj = this;
      var module = this.module;
      this.module.collection.filter({
        params: contrObj.filterCriteria,
        success: function(collection, data, response){

          Robin.layouts.main.getRegion('content').show(module.layout);

          var top_menu_view = new module.TopMenuView({
            model: new Robin.Models.NewsRoom(),
            collection: new Robin.Collections.Industries()
          });

          module.pagination_view = new module.PaginationView({
            model: new Robin.Models.Pagination ({
              page: contrObj.filterCriteria.page,
              per_page: contrObj.filterCriteria.per_page,
              total_count: parseInt(response.xhr.getResponseHeader('Totalcount'),10),
              total_pages: parseInt(response.xhr.getResponseHeader('Totalpages'),10)
            })
          });

          contrObj.renderCollectionView(collection, response);
          module.layout.topMenuRegion.show(top_menu_view);
          if(collection.length)
            module.layout.paginationRegion.show(module.pagination_view);
        }
      })
    },
    paginate: function(page){
      var contrObj = this;
      this.filterCriteria.page = page;
      this.module.collection.filter({
        params: contrObj.filterCriteria,
        success: function(collection, data, response){
          contrObj.renderCollectionView(collection, response);
          contrObj.module.pagination_view.model.set({
            page: page,
            per_page: contrObj.filterCriteria.per_page,
            total_count: parseInt(response.xhr.getResponseHeader('Totalcount'),10),
            total_pages: parseInt(response.xhr.getResponseHeader('Totalpages'),10)
          });
          $("html, body").scrollTop(0);
        }
      })
    },
    renderCollectionView: function (collection, response){
      var view = new this.module.CollectionView({
          collection:  collection,
          childView: this.module.ItemView
          // emptyView: CommitmentsEmptyView,
      });
      this.module.layout.mainContentRegion.show(view);
    }
  });
});