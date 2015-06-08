Robin.module('Analytics', function(Analytics, App, Backbone, Marionette, $, _){
  Analytics.Router = Marionette.AppRouter.extend({
    appRoutes: {
      'analytics': 'index',
      'analytics-email': 'emails'
    }
  });
});

