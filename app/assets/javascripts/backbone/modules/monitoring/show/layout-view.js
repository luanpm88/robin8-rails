Robin.module('Monitoring.Show', function(Show, App, Backbone, Marionette, $, _){
  Show.LayoutView = Backbone.Marionette.LayoutView.extend({
    template: 'modules/monitoring/show/templates/monitoring',

    tagName: "div",
    className: "streams-content",

    events: {
      'click #add-stream': 'addStream',
    },

    regions: {
      streamsRegion: "#streams-content",
    },

    initialize: function() {
    },

    onRender: function() {
      var currView = this;
      currView.$el.find("#add-stream").tooltip({title: 'Add Stream', trigger: 'hover', placement: 'left'});
      currView.streamsCollectionView = new Show.StreamsCollectionView({childView: Show.StreamCompositeView});
      currView.streamsRegion.show(currView.streamsCollectionView);
      currView.$el.find(".stream-container").sortable({
        handle: '.stream-header',
        start: function(e, ui) {
          $(e.target).data("ui-sortable").floating = true;
        },
        update: function(){
          var listOrder = [];
          $(currView.el).find('li.stream').each(function(i, list){
            var list_id = $(list).data('pos');
            listOrder.push(list_id);
          })
          $.ajax({
            type: 'POST',
            url: 'streams/order',
            data: {ids: listOrder},
            datatype: 'json',
            complete: function(request){
              console.log(request)
            },
          })
        }
      });
    },

    addStream: function() {
      var model = new Robin.Models.Stream();
      var stream = new Robin.Models.Stream({model: model});
      this.streamsCollectionView.collection.push(stream);
    },
  });
});