Robin.module('Newsroom', function(Newsroom, App, Backbone, Marionette, $, _){

  Newsroom.ItemView = Marionette.ItemView.extend({
    template: 'modules/news_room/templates/_item-view',
    events: {
      'click #open_edit': 'openEditModal'
    },
    onShow: function(){
      var descriptionArea = this.$el.find('.description_area p');
      descriptionArea.dotdotdot({
        ellipsis  : '... ',
        wrap    : 'word',
        fallbackToLetter: true,
        after   : null,
        watch   : false,
        height    : null,
        tolerance : 0,
        callback  : function( isTruncated, orgContent ) {
          if (isTruncated) {
            descriptionArea.tooltip({
              placement : 'top'
            });
          }
        },
      });

      var title = this.$el.find('.truncate-title');
      if (title.innerWidth() < title.prop('scrollWidth')) {
        title.tooltip({
          placement : 'top'
        });
      }
    },

    openEditModal: function(){
      Robin.vent.trigger("news_room:open_edit_modal", this.model);
    }
  });
});
