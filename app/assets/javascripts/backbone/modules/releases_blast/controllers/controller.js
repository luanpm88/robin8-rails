Robin.module('ReleasesBlast', function(ReleasesBlast, App, Backbone, Marionette, $, _){

  ReleasesBlast.Controller = Marionette.Controller.extend({
    initialize: function () {
      this.module = Robin.module("ReleasesBlast");
      var self = this;
      
      Robin.layouts.main.getRegion('content').show(this.module.layout);
      this.module.releasesBlastHeader = new Robin.Models.ReleasesBlastHeader();
      this.module.releasesBlastHeader.set({ level: 1 });
      this.module.topMenuView = new this.module.TopMenuView({
        pitchContactsCollection: this.module.pitchContactsCollection,
        model: this.module.releasesBlastHeader
      });
      this.module.layout.topMenuRegion.show(this.module.topMenuView);
      
      Robin.vent.on("search:authors:clicked", function(params) {
        self.searchAuthors(params);
      });
      
      Robin.vent.on("search:influencers:clicked", function(params) {
        self.searchInfluencers(params);
      });
    },
    start: function(params){
      this.module.releasesBlastHeader.set({ level: 1 });
      
      this.module.collection.fetch({reset: true});
      var startTabView = new this.module.StartTabView({
        collection: this.module.collection,
      });
      
      this.module.layout.tabContentRegion.show(startTabView);
    },
    analysis: function(params){
      this.module.releasesBlastHeader.set({ level: 2 });

      var releaseModel = this.module.collection.get(params.release_id);
      var iptcCategories = new Robin.Collections.IptcCategories();
      var analysisTabView = new this.module.AnalysisTabView({
        model: releaseModel,
        iptcCategories: iptcCategories
      });
      var pitchModel = new Robin.Models.Pitch({release_id: releaseModel.get('id')});
      pitchModel.save();
      this.module.pitch = pitchModel;
      this.module.layout.tabContentRegion.show(analysisTabView);
    },
    targets: function(params){
      this.module.releasesBlastHeader.set({ level: 3 });

      var releaseModel = this.module.collection.get(params.release_id);
      var targetsTabLayout = new ReleasesBlast.TargetsTabLayout();
      
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
      
      // Load Search tab
      this.module.searchLayout = new ReleasesBlast.SearchLayout();
      targetsTabLayout.searchRegion.show(this.module.searchLayout);
      
      var searchCriteriaView = new ReleasesBlast.SearchCriteriaView();
      this.module.searchLayout.searchCriteriaRegion.show(searchCriteriaView);
      
      // Load Media List tab
      var mediaListCollection = new Robin.Collections.MediaLists();
      var selectedMediaListsCollection = new Robin.Collections.SelectedMediaLists();
      
      mediaListCollection.fetch({reset: true});
      var mediaListLayout = new ReleasesBlast.MediaListLayout();
      targetsTabLayout.mediaListRegion.show(mediaListLayout);
      
      var uploadMediaListView = new ReleasesBlast.UploadMediaListView({
        collection: mediaListCollection,
        pitchContactsCollection: self.module.pitchContactsCollection,
        selectedMediaListsCollection: selectedMediaListsCollection
      });
      var selectedMediaListsView = new ReleasesBlast.SelectedMediaListsCompositeView({
        collection: selectedMediaListsCollection,
        pitchContactsCollection: self.module.pitchContactsCollection
      });
      
      mediaListLayout.selectedMediaListsRegion.show(selectedMediaListsView);
      mediaListLayout.uploadMediaListRegion.show(uploadMediaListView);
    },
    pitch: function(params){
      this.module.releasesBlastHeader.set({ level: 4 });

      var pitchTabView = new this.module.PitchTabView();
      this.module.layout.tabContentRegion.show(pitchTabView);

      var grouped = this.module.pitchContactsCollection.groupBy(function(c) {
        return c.get('origin');
      });

      var emailTargetsCollection = new ReleasesBlast.EmailTargetsCollection();
      var emails = grouped['pressr'] || [];
      _.chain(emails).map(function(e) {
        return new ReleasesBlast.EmailTargetModel({
          name: [e.get('first_name'), e.get('last_name')].join(' '),
          outlet: 1
        });
      }).each(function(e) { emailTargetsCollection.add(e); });

      var emailTargetsView = new ReleasesBlast.EmailTargetsView({
        collection: emailTargetsCollection
      });

      var twitterTargetsCollection = new ReleasesBlast.TwitterTargetsCollection();
      var twitters = grouped['twtrland'] || [];
      _.chain(twitters).map(function(t) {
        return new ReleasesBlast.TwitterTargetModel({
          name: [t.get('first_name'), t.get('last_name')].join(' '),
          handle: '@' + t.get('twitter_screen_name')
        })
      }).each(function(t) { twitterTargetsCollection.add(t); });
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
            collection: collection,
            pitchContactsCollection: self.module.pitchContactsCollection
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
            collection: collection,
            pitchContactsCollection: self.module.pitchContactsCollection
          });
          
          self.module.searchLayout.searchResultRegion.show(authorsCompositeView);
        }
      });
    }
  });
});
