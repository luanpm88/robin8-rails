Robin.module('ReleasesBlast', function(ReleasesBlast, App, Backbone, Marionette, $, _){

  ReleasesBlast.Controller = Marionette.Controller.extend({
    initialize: function () {
      this.module = Robin.module("ReleasesBlast");
    },
    start: function(params){
      Robin.layouts.main.getRegion('content').show(this.module.layout);
      var releasesCollection = new Robin.Collections.Releases();
      releasesCollection.fetch({reset: true});
      var topMenuView = new this.module.TopMenuView({level: 1});
      var startTabView = new this.module.StartTabView({
        collection: releasesCollection,
      });
      
      this.module.layout.topMenuRegion.show(topMenuView);
      this.module.layout.tabContentRegion.show(startTabView);
    },
    analysis: function(params){
      Robin.layouts.main.getRegion('content').show(this.module.layout);
      var topMenuView = new this.module.TopMenuView({level: 2});
      var analysisTabView = new this.module.AnalysisTabView(params);
      
      this.module.layout.topMenuRegion.show(topMenuView);
      this.module.layout.tabContentRegion.show(analysisTabView);
    },
    targets: function(params){
      Robin.layouts.main.getRegion('content').show(this.module.layout);
      var topMenuView = new this.module.TopMenuView({level: 3});
      var targetsTabView = new this.module.TargetsTabView();
      
      this.module.layout.topMenuRegion.show(topMenuView);
      this.module.layout.tabContentRegion.show(targetsTabView);
    },
    pitch: function(params){
      Robin.layouts.main.getRegion('content').show(this.module.layout);
      var topMenuView = new this.module.TopMenuView({level: 4});
      var pitchTabView = new this.module.PitchTabView();
      
      this.module.layout.topMenuRegion.show(topMenuView);
      this.module.layout.tabContentRegion.show(pitchTabView);
    }
  });
});
