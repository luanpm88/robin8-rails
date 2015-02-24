Robin.module('Releases', function(Releases, App, Backbone, Marionette, $, _){

  Releases.Controller = Marionette.Controller.extend({
    page: 1,
    per_page: 9,

    initialize: function () {
      this.module = Robin.module("Releases");
    },
    indexBy: function(newsroom){
      this.index({by_news_room: newsroom});
    },
    index: function(params){
      var controller  = this;

      controller.filterCriteria = {
        page: controller.page,
        per_page: controller.per_page
      };

      if (params){
        _.each(params, function(v,k){
          if (v !== ""){
            controller.filterCriteria[k] = v;
          } else {
            delete controller.filterCriteria[k];
          }
        });
      }
      var contrObj = this;
      var module = this.module;
      this.module.collection.filter({
        params: contrObj.filterCriteria,
        success: function(collection, data, response){

          Robin.layouts.main.getRegion('content').show(module.layout);

          module.top_menu_view.model = new Robin.Models.Release(controller.filterCriteria)

          module.pagination_view = new module.PaginationView({
            model: new Robin.Models.Pagination ({
              page: contrObj.filterCriteria.page,
              per_page: contrObj.filterCriteria.per_page,
              total_count: parseInt(response.xhr.getResponseHeader('Totalcount'),10),
              total_pages: parseInt(response.xhr.getResponseHeader('Totalpages'),10)
            })
          });

          contrObj.renderCollectionView(collection, response);
          module.layout.topMenuRegion.show(module.top_menu_view);
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
          $("html, body").animate({ scrollTop: $(document).height() }, 1000);
        }
      })
    },
    renderCollectionView: function (collection, response){
      var view = new this.module.CollectionView({
          collection:  collection,
          childView: this.module.ItemView
      });
      this.module.layout.mainContentRegion.show(view);
    }
  });
});