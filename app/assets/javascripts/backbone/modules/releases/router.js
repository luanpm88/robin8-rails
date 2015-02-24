Robin.module('Releases', function(Releases, App, Backbone, Marionette, $, _){
  Releases.Router = Marionette.AppRouter.extend({
    appRoutes: {
      'releases': 'index',
      'releases/newsroom/:id': 'indexBy'
    }
  });
});

