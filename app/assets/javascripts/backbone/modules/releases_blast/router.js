Robin.module('ReleasesBlast', function(ReleasesBlast, App, Backbone, Marionette, $, _){
  ReleasesBlast.Router = Marionette.AppRouter.extend({
    appRoutes: {
      'robin8': 'start',
      'robin8/analysis': 'analysis',
      'robin8/targets': 'targets',
      'robin8/pitch': 'pitch'
    }
  });
});

