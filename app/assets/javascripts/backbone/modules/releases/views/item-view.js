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
        first_src = AppAssets.path('release-btn.png');
      }
      this.model.attributes.first_src = first_src;
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
