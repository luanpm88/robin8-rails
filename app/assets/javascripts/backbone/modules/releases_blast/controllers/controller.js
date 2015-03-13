Robin.module('ReleasesBlast', function(ReleasesBlast, App, Backbone, Marionette, $, _){

  ReleasesBlast.Controller = Marionette.Controller.extend({
    initialize: function () {
      this.module = Robin.module("ReleasesBlast");
      var self = this;
      
      Robin.layouts.main.getRegion('content').show(this.module.layout);
      this.module.releasesBlastHeader = new Robin.Models.ReleasesBlastHeader();
      this.module.releasesBlastHeader.set({ level: 1 });
      this.module.topMenuView = new this.module.TopMenuView({
        pitchContactsCollection: this.module.pitchModel.get('contacts'),
        model: this.module.releasesBlastHeader
      });
      this.module.layout.topMenuRegion.show(this.module.topMenuView);
      
      Robin.vent.on("search:authors:clicked", function(params) {
        self.searchAuthors(params);
      });
      
      Robin.vent.on("search:influencers:clicked", function(params) {
        self.searchInfluencers(params);
      });
      
      Robin.vent.on("targets:tab:clicked", function(params){
        if (self.module.releasesBlastHeader.get('level') === 4)
          self.targets();
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

      this.module.releaseModel = params.releaseModel;
      var analysisTabView = new this.module.AnalysisTabView({
        model: this.module.releaseModel
      });
      this.module.layout.tabContentRegion.show(analysisTabView);
    },
    targets: function(){
      this.module.releasesBlastHeader.set({ level: 3 });
      var self = this;

      var targetsTabLayout = new ReleasesBlast.TargetsTabLayout({
        collection: this.module.pitchModel.get('contacts')
      });
      this.module.layout.tabContentRegion.show(targetsTabLayout);
      
      // Loading view
      targetsTabLayout.blogsRegion.show(new Robin.Components.Loading.LoadingView());
      targetsTabLayout.socialRegion.show(new Robin.Components.Loading.LoadingView());
      // END Loading view
      
      var suggestedAuthorsCollection = new Robin.Collections.SuggestedAuthors({
        releaseModel: this.module.releaseModel
      });
      suggestedAuthorsCollection.fetchAuthors({
        success: function(collection, data, response){
          var blogTargetView = new ReleasesBlast.BlogTargetsCompositeView({
            collection: collection,
            releaseModel: self.module.releaseModel,
            pitchContactsCollection: self.module.pitchModel.get('contacts')
          });
          targetsTabLayout.blogsRegion.show(blogTargetView);
        }
      });
      
      var influencersCollection = new Robin.Collections.Influencers({
        releaseModel: this.module.releaseModel
      });
      influencersCollection.fetchInfluencers({
        success: function(collection, data, response){
          var socialTargetsView = new ReleasesBlast.SocialTargetsCompositeView({
            collection: collection,
            pitchContactsCollection: self.module.pitchModel.get('contacts'),
            releaseModel: self.module.releaseModel
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
        pitchContactsCollection: self.module.pitchModel.get('contacts'),
        selectedMediaListsCollection: selectedMediaListsCollection
      });
      var selectedMediaListsView = new ReleasesBlast.SelectedMediaListsCompositeView({
        collection: selectedMediaListsCollection,
        pitchContactsCollection: self.module.pitchModel.get('contacts')
      });
      
      mediaListLayout.selectedMediaListsRegion.show(selectedMediaListsView);
      mediaListLayout.uploadMediaListRegion.show(uploadMediaListView);
    },
    pitch: function(params){
      this.module.releasesBlastHeader.set({ level: 4 });

      var pitchTabView = new this.module.PitchTabView({
        model: this.module.pitchModel,
        releaseModel: this.module.releaseModel
      });
      this.module.layout.tabContentRegion.show(pitchTabView);

      var pressrContacts = this.module.pitchModel.get('contacts').getPressrContacts();
      var mediaListContacts = this.module.pitchModel.get('contacts').getMediaListContacts();
      var twtrlandContacts = this.module.pitchModel.get('contacts').getTwtrlandContacts();
      
      var emailTargetsCollection = new Robin.Collections.EmailTargetsCollection(
        pressrContacts.concat(mediaListContacts)
      );
      var mediaList = new Robin.Models.MediaList();
      
      var emailTargetsView = new ReleasesBlast.EmailTargetsView({
        collection: emailTargetsCollection,
        model: mediaList
      });

      var twitterTargetsCollection = new Robin.Collections.TwitterTargetsCollection(
        twtrlandContacts
      );
      var twitterTargetsView = new ReleasesBlast.TwitterTargetsView({
        collection: twitterTargetsCollection
      });

      pitchTabView.emailTargets.show(emailTargetsView);
      pitchTabView.twitterTargets.show(twitterTargetsView);
      
      var emailPitchView = new ReleasesBlast.EmailPitchView({
        model: this.module.pitchModel
      }); 
      pitchTabView.emailPitch.show(emailPitchView);
      
      var twitterPitchView = new ReleasesBlast.TwitterPitchView({
        releaseModel: this.module.releaseModel,
        model: this.module.pitchModel
      });
      pitchTabView.twitterPitch.show(twitterPitchView);
    },

    searchInfluencers: function(params){
      var self = this;
      var influencersCollection = new Robin.Collections.Influencers();
      
      // Loading view
      this.module.searchLayout.searchResultRegion.show(
        new Robin.Components.Loading.LoadingView()
      );
      // END Loading view
      
      influencersCollection.findInfluencers(params, {
        success: function(collection, data, response){
          var influencersCompositeView = new ReleasesBlast.SocialTargetsCompositeView({
            collection: collection,
            pitchContactsCollection: self.module.pitchModel.get('contacts'),
            releaseModel: self.module.releaseModel
          });
          
          self.module.searchLayout.searchResultRegion.show(influencersCompositeView);
        }
      });
    },
    
    searchAuthors: function(params){
      var self = this;
      var authorsCollection = new Robin.Collections.Authors();
      
      // Loading view
      this.module.searchLayout.searchResultRegion.show(
        new Robin.Components.Loading.LoadingView()
      );
      // END Loading view
      
      authorsCollection.fetchAuthors(params, {
        success: function(collection, data, response){
          var authorsCompositeView = new ReleasesBlast.AuthorsCompositeView({
            collection: collection,
            releaseModel: self.module.releaseModel,
            pitchContactsCollection: self.module.pitchModel.get('contacts')
          });
          
          self.module.searchLayout.searchResultRegion.show(authorsCompositeView);
        }
      });
    }
  });
});
