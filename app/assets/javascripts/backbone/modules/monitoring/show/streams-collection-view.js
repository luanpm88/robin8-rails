Robin.module('Monitoring.Show', function(Show, App, Backbone, Marionette, $, _){

  Show.StreamsCollectionView = Backbone.Marionette.CollectionView.extend({

    tagName: "ul",
    className: "stream-container",

    collection: new Robin.Collections.Streams(),

    initialize: function() {
      this.collection.fetch();
    },

    onRender: function() {
    }
  });

});
