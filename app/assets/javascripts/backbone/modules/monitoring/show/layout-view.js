Robin.module('Monitoring.Show', function(Show, App, Backbone, Marionette, $, _){
  Show.LayoutView = Backbone.Marionette.LayoutView.extend({
    template: 'modules/monitoring/show/templates/monitoring',

    events: {
      'click #add-stream': 'addStream',
    },

    regions: {
      streamsRegion: "#streams-content",
    },

    initialize: function() {
    },

    addStream: function() {
      var model = new Robin.Models.Stream();
      var stream = new Robin.Models.Stream({model: model});
      this.streamsCollectionView.collection.push(stream);
    },

    onRender: function() {
      this.streamsCollectionView = new Show.StreamsCollectionView({childView: Show.StreamItemView});
      this.streamsRegion.show(this.streamsCollectionView);
      this.$el.find(".stream-container").sortable({handle: '.stream-header'});
      this.$el.find(".stream-container").disableSelection();
    },
  });
});