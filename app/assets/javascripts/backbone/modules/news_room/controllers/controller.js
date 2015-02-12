Robin.module('Newsroom', function(Newsroom, App, Backbone, Marionette, $, _){

  Newsroom.Controller = Marionette.Controller.extend({
    initialize: function () {
      this.module = Robin.module("Newsroom");
      this.filterCriteria = {
        page: 1,
        per_page:5
      };
    },
    index: function(){
      var contrObj = this;
      var module = this.module;
      this.module.collection.filter({
        params: contrObj.filterCriteria,
        success: function(collection){
          Robin.layouts.main.getRegion('content').show(module.layout);
          var top_menu_view = new module.TopMenuView({});
          var view = new module.CollectionView({
              collection:  collection,
              childView: module.ItemView
              // emptyView: CommitmentsEmptyView,
          });
          module.layout.mainContentRegion.show(view);
          module.layout.topMenuRegion.show(top_menu_view);
        }
      })
    }
  });
});