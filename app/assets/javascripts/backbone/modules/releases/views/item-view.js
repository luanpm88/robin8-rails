Robin.module('Releases', function(Releases, App, Backbone, Marionette, $, _){

  Releases.ItemView = Marionette.ItemView.extend({
    template: 'modules/releases/templates/item-view',
    events: {
      'click #open_edit': 'openEditModal',
      'click #start-blast': 'startSmartRelease'
    },

    initialize: function(){
      if (this.model.attributes.thumbnail) {
        first_src = this.model.attributes.thumbnail;
      } else {
        first_src="http://placehold.it/542x542";
      }
      this.model.attributes.first_src = first_src;
    },

    onShow: function(){
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

    startSmartRelease: function(options){
      Robin.releaseForBlast = this.model.get('id');
      Backbone.history.navigate('robin8', {trigger: true});
    },

    openEditModal: function(){
      Robin.vent.trigger("release:open_edit_modal", this.model);
    }

  });
});
