Robin.module('CnRecommendations', function(CnRecommendations, App, Backbone, Marionette, $, _){
  CnRecommendations.ItemView = Marionette.ItemView.extend({
    template: "modules/cn_recommendations/templates/cn_recommendation",
    model: Robin.Models.CnRecommendtaion,
    className: "cn_recommendation",
    tagName: "div",

    initialize: function(){
      this.listenTo(this.model, "change", this.render);
    },

    onRender: function(){
      console.log("加载了 model view")
    },
  });

  CnRecommendations.CollectionView = Marionette.CollectionView.extend({
    childView: CnRecommendations.ItemView,
    collection: Robin.Collections.CnRecommendations,
    className: "cn_recommendations",
    tagName: "div",

    onRender: function(){
      console.log("加载了 collection view");
    }
  });
});