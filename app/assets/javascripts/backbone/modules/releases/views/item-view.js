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

    onRender: function(){
      if (Robin.user.get('can_create_smart_release') != true) {
        this.$el.find("#start-blast").addClass('disabled-unavailable');
      } else {
        this.$el.find("#start-blast").removeClass('disabled-unavailable');
      }
    },

    onShow: function(){
      var descriptionArea = this.$el.find('.release-title');
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
    },

    startSmartRelease: function(options){
      if (Robin.user.get('can_create_smart_release') != true) {
        $.growl({message: "You don't have available smart-content!"},
          {
            type: 'info'
          }); 
      } else {
        Robin.releaseForBlast = this.model.get('id');
        Backbone.history.navigate('robin8', {trigger: true});
      }
    },

    openEditModal: function(){
      Robin.vent.trigger("release:open_edit_modal", this.model);
    }

  });
});