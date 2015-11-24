Robin.module("CnRecommendations", function(CnRecommendations, App, Backbone, Marionette, $, _){
  CnRecommendations.Layout = Marionette.LayoutView.extend({
    template: "modules/cn_recommendations/templates/layout",
    regions: {
      main: "#recommendations-container"
    }
  })
});