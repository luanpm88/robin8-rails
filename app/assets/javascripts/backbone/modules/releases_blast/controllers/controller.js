Robin.module('ReleasesBlast', function(ReleasesBlast, App, Backbone, Marionette, $, _){

  ReleasesBlast.Controller = Marionette.Controller.extend({
    initialize: function () {
      this.module = Robin.module("ReleasesBlast");
    },
    start: function(params){
      Robin.layouts.main.getRegion('content').show(this.module.layout);
      this.module.collection.fetch({reset: true});
      var topMenuView = new this.module.TopMenuView({level: 1});
      var startTabView = new this.module.StartTabView({
        collection: this.module.collection,
      });
      
      this.module.layout.topMenuRegion.show(topMenuView);
      this.module.layout.tabContentRegion.show(startTabView);
    },
    analysis: function(params){
      Robin.layouts.main.getRegion('content').show(this.module.layout);
      var releaseModel = this.module.collection.get(params.release_id);
      var topMenuView = new this.module.TopMenuView({level: 2});
      var analysisTabView = new this.module.AnalysisTabView({model: releaseModel});
      
      this.module.layout.topMenuRegion.show(topMenuView);
      this.module.layout.tabContentRegion.show(analysisTabView);
    },
    targets: function(params){
      Robin.layouts.main.getRegion('content').show(this.module.layout);
      var releaseModel = this.module.collection.get(params.release_id);
      var topMenuView = new this.module.TopMenuView({level: 3});
      var targetsTabLayout = new ReleasesBlast.TargetsTabLayout();
      
      this.module.layout.topMenuRegion.show(topMenuView);
      this.module.layout.tabContentRegion.show(targetsTabLayout);
      
      var suggestedAuthorsCollection = new Robin.Collections.SuggestedAuthors({
        releaseModel: releaseModel
      });
      
      var influencersCollection = new Robin.Collections.Influencers({
        releaseModel: releaseModel
      });
      
      var blogTargetView = new ReleasesBlast.BlogTargetsView({
        collection: suggestedAuthorsCollection
      });
      
      var socialTargetsView = new ReleasesBlast.SocialTargetsView({
        collection: influencersCollection
      });
      
      targetsTabLayout.blogsRegion.show(blogTargetView);
      targetsTabLayout.socialRegion.show(socialTargetsView);
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
