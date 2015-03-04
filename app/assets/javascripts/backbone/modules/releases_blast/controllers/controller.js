Robin.module('ReleasesBlast', function(ReleasesBlast, App, Backbone, Marionette, $, _){

  ReleasesBlast.Controller = Marionette.Controller.extend({
    initialize: function () {
      this.module = Robin.module("ReleasesBlast");
      var self = this;
      
      Robin.vent.on("search:authors:clicked", function(params) {
        self.searchAuthors(params);
      });
      
      Robin.vent.on("search:influencers:clicked", function(params) {
        self.searchInfluencers(params);
      });
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
      var iptcCategories = new Robin.Collections.IptcCategories();
      var analysisTabView = new this.module.AnalysisTabView({
        model: releaseModel,
        iptcCategories: iptcCategories
      });
      var pitchModel = new Robin.Models.Pitch({release_id: releaseModel.get('id')});
      pitchModel.save();
      this.module.pitch = pitchModel;
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
      var self = this;
      suggestedAuthorsCollection.fetchAuthors({
        success: function(collection, data, response){
          var blogTargetView = new ReleasesBlast.BlogTargetsCompositeView({
            collection: collection,
            releaseModel: releaseModel,
            pitchContactsCollection: self.module.pitchContactsCollection
          });
          targetsTabLayout.blogsRegion.show(blogTargetView);
        }
      });
      
      var influencersCollection = new Robin.Collections.Influencers({
        releaseModel: releaseModel
      });
      influencersCollection.fetchInfluencers({
        success: function(collection, data, response){
          var socialTargetsView = new ReleasesBlast.SocialTargetsCompositeView({
            collection: collection,
            pitchContactsCollection: self.module.pitchContactsCollection
          });
          
          targetsTabLayout.socialRegion.show(socialTargetsView);
        }
      });
      
      this.module.searchLayout = new ReleasesBlast.SearchLayout();
      targetsTabLayout.searchRegion.show(this.module.searchLayout);
      
      var searchCriteriaView = new ReleasesBlast.SearchCriteriaView();
      this.module.searchLayout.searchCriteriaRegion.show(searchCriteriaView);
    },
    pitch: function(params){
      Robin.layouts.main.getRegion('content').show(this.module.layout);
      var topMenuView = new this.module.TopMenuView({level: 4});
      var pitchTabView = new this.module.PitchTabView();
      this.module.layout.topMenuRegion.show(topMenuView);
      this.module.layout.tabContentRegion.show(pitchTabView);

      var emailTargetsCollection = new ReleasesBlast.EmailTargetsCollection();
      _.chain(_.range(7)).map(function(i) {
        return new ReleasesBlast.EmailTargetModel({name: 'Target ' + i, outlet: i});
      }).each(function(m) { emailTargetsCollection.add(m); })
      var emailTargetsView = new ReleasesBlast.EmailTargetsView({
        collection: emailTargetsCollection
      });

      var twitterTargetsCollection = new ReleasesBlast.TwitterTargetsCollection();
      _.chain(_.range(5)).map(function(i) {
        return new ReleasesBlast.TwitterTargetModel({name: 'Target ' + i, handle: '@target' + i});
      }).each(function(m) { twitterTargetsCollection.add(m); });
      var twitterTargetsView = new ReleasesBlast.TwitterTargetsView({
        collection: twitterTargetsCollection
      });

      pitchTabView.emailTargets.show(emailTargetsView);
      pitchTabView.twitterTargets.show(twitterTargetsView);
      pitchTabView.emailPitch.show(new ReleasesBlast.EmailPitchView());
      pitchTabView.twitterPitch.show(new ReleasesBlast.TwitterPitchView({hashTags: ["#ios", "#android"]}));
    },

    searchInfluencers: function(params){
      var self = this;
      var influencersCollection = new Robin.Collections.Influencers();
      
      influencersCollection.findInfluencers(params, {
        success: function(collection, data, response){
          var influencersCompositeView = new ReleasesBlast.SocialTargetsCompositeView({
            collection: collection
          });
          
          self.module.searchLayout.searchResultRegion.show(influencersCompositeView);
        }
      });
    },
    
    searchAuthors: function(params){
      var self = this;
      var authorsCollection = new Robin.Collections.Authors();
      
      authorsCollection.fetchAuthors(params, {
        success: function(collection, data, response){
          var authorsCompositeView = new ReleasesBlast.AuthorsCompositeView({
            collection: collection
          });
          
          self.module.searchLayout.searchResultRegion.show(authorsCompositeView);
        }
      });
    }
  });
});
