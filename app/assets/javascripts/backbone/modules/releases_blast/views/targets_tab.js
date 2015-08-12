Robin.module('ReleasesBlast', function(ReleasesBlast, App, Backbone, Marionette, $, _){

  ReleasesBlast.TargetsTabLayout = Marionette.LayoutView.extend({
    template: 'modules/releases_blast/templates/targets_tab/layout',
    ui: {
      nextButton: '#next-step'
    },
    events: {
      "click @ui.nextButton": "openPitchTab"
    },
    regions: {
      blogsRegion: "#targets-blogs",
      socialRegion: "#targets-social",
      searchRegion: "#targets-search",
      mediaListRegion: "#targets-list"
    },
    openPitchTab: function(){
      ReleasesBlast.controller.pitch();
    },
    collectionEvents: {
      "add": "contactAdded",
      "remove": "contactRemoved"
    },
    contactAdded: function(){
      if (this.collection.length == 1)
        this.ui.nextButton.prop('disabled', false);
    },
    contactRemoved: function(){
      if (this.collection.length == 0)
        this.ui.nextButton.prop('disabled', true);
    },
    onShow: function(){
      if (this.collection.length > 0)
        this.ui.nextButton.prop('disabled', false);
    },
    initialize: function(options){
      var self = this;
      Robin.commands.setHandler("goToPitchTab", function(){
        if (self.ui.nextButton.prop('disabled') === false)
          self.openPitchTab();
      });
      
      this.on("close", function(){ 
        Robin.commands.removeHandler("goToPitchTab");
        Robin.vent.off("search:authors:clicked");
        Robin.vent.off("search:influencers:clicked");
      });
    },

    onRender: function(){
      var curView = this;
      Robin.user.fetch({
        success: function() {
          if (Robin.user.get('can_create_media_list') != true) {
            curView.$el.find("#upload_button").addClass('disabled-unavailable');
          } else {
            curView.$el.find("#upload_button").removeClass('disabled-unavailable');
          }
        }
      });
    },
  });
});
