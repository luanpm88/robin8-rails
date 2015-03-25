Robin.module('Releases', function(Releases, App, Backbone, Marionette, $, _){

  Releases.ItemView = Marionette.ItemView.extend({
    template: 'modules/releases/templates/item-view',
    events: {
      'click #open_edit': 'openEditModal'
    },

    initialize: function(){
      if (this.model.attributes.thumbnail) {
        first_src = this.model.attributes.thumbnail;
      } else {
        first_src="http://placehold.it/340x340";
      }
      this.model.attributes.first_src = first_src;
    },

    onShow: function(){
      $('.nailthumb-square-340').nailthumb({width:340,height:340,method:'resize',fitDirection:'center'});
      var descriptionArea = this.$el.find('.release-title');
      descriptionArea.dotdotdot({
        ellipsis : '... ',
        wrap: 'word',
        fallbackToLetter: true,
        after: null,
        watch: false,
        tolerance: 0
      });
    },

    openEditModal: function(){
      Robin.vent.trigger("release:open_edit_modal", this.model);
    }

  });
});
