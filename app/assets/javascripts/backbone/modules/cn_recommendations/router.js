Robin.module("CnRecommendations", function(Recommendations, App, Backbone, Marionette, $, _){
  Recommendations.Router = Marionette.AppRouter.extend({
    appRoutes: {
      'cn-recommendations': "index"
    }
  })
});