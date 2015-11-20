Robin.module("CnRecommendations", function(CnRecommendations, App, Backbone, Marionette, $, _){
  CnRecommendations.Controller = Marionette.Controller.extend(
  {
    initialize: function(){
      var self = this;
      self.module = Robin.module("CnRecommendations");
      console.log("start cn recommendations init");
    },

    index: function(){
      console.log("start cn recommendations index");
      Robin.layouts.main.content.show(CnRecommendations.layout);
      this.showRecommendations();
    },

    showRecommendations: function(){
      var module = this.module;
      console.log("begin fetch data")
      this.collection = new Robin.Collections.CnRecommendations();
      console.log("begin fetch data 2");
      this.collection.fetch(
      {
        // 添加 失败的 callback
        success: function(recommendations){
          console.log("获取到recommendations 数据");
          if(recommendations.length > 0){
            var recommendationsView = new CnRecommendations.CollectionView({collection: recommendations})
            module.layout.main.show(recommendationsView)
          }
        },
        data: {page: 0},
        processData: true
      }
      );
    }
  }
  );
});