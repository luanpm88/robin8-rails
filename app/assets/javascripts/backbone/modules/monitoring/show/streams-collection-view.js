Robin.module('Monitoring.Show', function(Show, App, Backbone, Marionette, $, _){

  Show.StreamsCollectionView = Backbone.Marionette.CollectionView.extend({

    tagName: "ul",
    className: "stream-container",

    collection: new Robin.Collections.Streams(),

    initialize: function() {
      this.collection.fetch({
        success: this.addStream(),
      });
    },

    onRender: function() {
      var view = this;
      if (Robin.newStreamFromDashboard) {
        setTimeout(function(){ view.$el.scrollLeft(view.el.scrollWidth); }, 500);
        Robin.newStreamFromDashboard = false
      }
    },

    addStream: function() {
      if (Robin.newStreamFromDashboard) {
        var model = new Robin.Models.Stream();
        var stream = new Robin.Models.Stream({model: model});
        stream.save();
        this.collection.push(stream);
        this.$el.scrollLeft(this.$el.scrollWidth);
      }
    }

  });

});
