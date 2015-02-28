Robin.module('ReleasesBlast', function(ReleasesBlast, App, Backbone, Marionette, $, _){

  ReleasesBlast.TargetsTabLayout = Marionette.LayoutView.extend({
    template: 'modules/releases_blast/templates/targets-tab-layout',
    events: {
      "click #next-step": "openPitchTab"
    },
    regions: {
      blogsRegion: "#targets-blogs",
      socialRegion: "#targets-social",
      searchRegion: "#targets-search",
      mediaListRegion: "#targets-list"
    },
    openPitchTab: function(){
      ReleasesBlast.controller.pitch();
    }
  });
});
