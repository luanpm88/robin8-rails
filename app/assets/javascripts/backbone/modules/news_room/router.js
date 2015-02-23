Robin.module('Newsroom', function(Newsroom, App, Backbone, Marionette, $, _){
  Newsroom.Router = Marionette.AppRouter.extend({
    appRoutes: {
      'news_rooms': 'index'
    }
  });
});

