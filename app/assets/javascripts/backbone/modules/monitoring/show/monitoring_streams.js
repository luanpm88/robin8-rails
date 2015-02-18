Robin.module('Monitoring.Show', function(Show, App, Backbone, Marionette, $, _){

  Show.MonitoringStreamsView = Backbone.Marionette.CollectionView.extend({

    tagName: "ul",
    className: "stream-container",

    childView: Show.MonitoringStreamView,
    collection: new Robin.Collections.Streams(),

    initialize: function() {
      this.collection.fetch();
    },

    onRender: function() {
    }
  });

});
