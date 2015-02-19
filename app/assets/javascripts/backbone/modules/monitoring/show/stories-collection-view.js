Robin.module('Monitoring.Show', function(Show, App, Backbone, Marionette, $, _){

  Show.StoriesCollectionView = Backbone.Marionette.CollectionView.extend({

    tagName: "ul",
    className: "stories",

    initialize: function() {
      this.collection.fetch({reset: true});
    },

    onRender: function() {
    }
  });

});
