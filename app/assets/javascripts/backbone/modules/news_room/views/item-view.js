Robin.module('Newsroom', function(Newsroom, App, Backbone, Marionette, $, _){

  Newsroom.ItemView = Marionette.ItemView.extend({
    template: 'modules/news_room/templates/_item-view',
    events: {
      'click #open_edit': 'openEditModal'
    },
    openEditModal: function(){
      Robin.vent.trigger("news_room:open_edit_modal", this.model);
    }
  });
});
