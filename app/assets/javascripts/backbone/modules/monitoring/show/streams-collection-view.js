Robin.module('Monitoring.Show', function(Show, App, Backbone, Marionette, $, _){

  Show.StreamsCollectionView = Backbone.Marionette.CollectionView.extend({

    tagName: "ul",
    className: "stream-container",

    collection: new Robin.Collections.Streams(),

    initialize: function() {
      var view = this;
      var collection = this.collection;
      collection.fetch({
        success: function(model, response){
          if (Robin.newStreamFromDashboard) {
            var model = new Robin.Models.Stream();
            var stream = new Robin.Models.Stream({model: model});
            collection.push(stream);
            view.$el.scrollLeft(view.$el.scrollWidth);
            setTimeout(function(){ view.$el.scrollLeft(view.el.scrollWidth); }, 500);
            Robin.newStreamFromDashboard = false
          }
        }
      });
    },

    onRender: function() {
    },

  });

});
