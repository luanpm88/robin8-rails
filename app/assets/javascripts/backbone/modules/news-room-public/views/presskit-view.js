Robin.module('NewsRoomPublic', function(NewsRoomPublic, App, Backbone, Marionette, $, _){

  NewsRoomPublic.PresskitView = Marionette.CompositeView.extend({
    template: 'modules/news-room-public/templates/presskit',
    childViewContainer: '#presskit',
    events: {
      'click #presskit': 'enableBlueimp'
    },

    onRender: function() {
      var $container = this.$el.find('#presskit');
      $container.imagesLoaded( function() {
        $container.masonry({
          columnWidth: $container.width()/3,
          gutter: 0,
          itemSelector: 'a'
        });
      });
    },

    enableBlueimp: function(event) {
      event = event || window.event;
      var target = event.target || event.srcElement,
        link = target.src ? target.parentNode : target,
        options = {index: link, event: event},
        links = this.$el.find('a');
      blueimp.Gallery(links, options);
    }

  });

});
