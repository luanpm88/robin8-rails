Robin.module('NewsRoomPublic', function(NewsRoomPublic, App, Backbone, Marionette, $, _){

  NewsRoomPublic.Router = Backbone.Marionette.AppRouter.extend({

    appRoutes: {
      "news-room": "index",
      "presskit": "presskit",
      "release/:id": "release"
    }

  });

});