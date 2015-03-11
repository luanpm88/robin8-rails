Robin.module('Releases', function(Releases, App, Backbone, Marionette, $, _){

  Releases.ItemView = Marionette.ItemView.extend({
    template: 'modules/releases/templates/item-view',
    events: {
      'click #open_edit': 'openEditModal'
    },
    onShow: function(){
      $(".release-title").dotdotdot();
    },
    openEditModal: function(){
      Robin.vent.trigger("release:open_edit_modal", this.model);
    }
  });
});
