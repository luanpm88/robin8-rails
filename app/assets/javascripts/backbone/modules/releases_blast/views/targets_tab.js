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
    }
  });
});
