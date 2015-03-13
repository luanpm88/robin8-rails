Robin.module('Releases', function(Releases, App, Backbone, Marionette, $, _){

  Releases.ItemView = Marionette.ItemView.extend({
    template: 'modules/releases/templates/item-view',
    events: {
      'click #open_edit': 'openEditModal'
    },

    initialize: function(){
      var attachments = this.model.attributes.attachments;
      if (this.model.attributes.logo_url) {
        first_src = this.model.attributes.logo_url;
      } else {
        if(attachments.length > 0) {
          var t = true 
          _.every(attachments, function(attachment){
            if(attachment.attachment_type == 'image') {
              first_src = attachment.url;
              t = false;
            }
            return t;
          }); 
        } else {
          first_src="http://placehold.it/542x542";
        }
      }
      this.model.attributes.first_src = first_src; 
    },

    onShow: function(){
      var title = this.$el.find('.truncate');
      if (title.innerWidth() < title.prop('scrollWidth')) {
        title.tooltip({
          placement : 'top'
        });
      }
    },

    openEditModal: function(){
      Robin.vent.trigger("release:open_edit_modal", this.model);
    }

  });
});
