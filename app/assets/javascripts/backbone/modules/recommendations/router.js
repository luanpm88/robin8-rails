Robin.module('Recommendations', function(Recommendations, App, Backbone, Marionette, $, _){
  Recommendations.Router = Marionette.AppRouter.extend({
    appRoutes: {
      'recommendations': 'index'
    }
  });
});

