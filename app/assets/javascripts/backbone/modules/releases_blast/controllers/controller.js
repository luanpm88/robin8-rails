Robin.module('ReleasesBlast', function(ReleasesBlast, App, Backbone, Marionette, $, _){

  ReleasesBlast.Controller = Marionette.Controller.extend({
    initialize: function () {
      var self = this;
      this.module = Robin.module("ReleasesBlast");
      Robin.user = new Robin.Models.User();
      Robin.user.fetch({
        success: function() {
          self.module.topMenuView.render();
          self.module.topMenuView.$el.find(".badge-tooltip").tooltip({title: 'Available smart-releases count', trigger: 'hover', placement: 'right'});
        }
      })
      this.module.selectedMediaListsCollection = new Robin.Collections.SelectedMediaLists();
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
      
      
      Robin.vent.on("start:tab:clicked", function(params){
        if ([2, 3, 4].indexOf(self.module.releasesBlastHeader.get('level')) !== -1){
          self.module.trigger("stop", {restart: true});
        }
      });
      
      Robin.vent.on("analysis:tab:clicked", function(params){
        if (self.module.pitchModel.get('sent') === false){
          if (self.module.releasesBlastHeader.get('level') === 1)
            Robin.commands.execute("goToAnalysisTab");
          else if ([3, 4].indexOf(self.module.releasesBlastHeader.get('level')) !== -1)
            self.analysis({releaseModel: self.module.releaseModel});
        }
      });
      
      Robin.commands.setHandler("reloadTargetsTab", function(){
        self.targets();
      });
      
      Robin.vent.on("targets:tab:clicked", function(params){
        if (self.module.pitchModel.get('sent') === false){
          if (self.module.releasesBlastHeader.get('level') === 4)
            self.targets();
          else if (self.module.releasesBlastHeader.get('level') === 2)
            Robin.commands.execute("goToTargetsTab");
        }
      });
      
      Robin.vent.on("pitch:tab:clicked", function(params){
        if (self.module.pitchModel.get('sent') === false){
          if (self.module.releasesBlastHeader.get('level') === 3)
            Robin.commands.execute("goToPitchTab");
        }
      });
      
      this.on('destroy', function(){
        Robin.vent.off("start:tab:clicked");
        Robin.vent.off("analysis:tab:clicked");
        Robin.vent.off("targets:tab:clicked");
        Robin.vent.off("pitch:tab:clicked");
      });
    },
    start: function(params){
      this.module.collection.fetch({reset: true, data: { "for_blast": true}});
      var startTabView = new this.module.StartTabView({
        collection: this.module.collection,
        pitchModel: this.module.pitchModel,
        draftPitchModel: this.module.draftPitchModel
      });

      if (Robin.releaseForBlast != undefined) {
        this.module.releasesBlastHeader.set({ level: 2 });
      } else {
        this.module.releasesBlastHeader.set({ level: 1 });
        this.module.layout.tabContentRegion.show(startTabView);
      };
      
    },
    analysis: function(params){
      this.module.releasesBlastHeader.set({ level: 2 });

      this.module.releaseModel = params.releaseModel;

      ////////////// Submit event to Wripl for recommendations //
      var keywords ="", 
      topics = this.module.releaseModel.attributes['concepts'].slice(0, 6).join(), 
      category = this.module.releaseModel.attributes['iptc_categories'].slice(0, 6).join(); 
      wripl._track(Robin.currentUser.attributes['id'], 0, "VIEW", keywords, topics, category);
      //////////// End of Wripl event capture ///////////////// 
      
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
      
      mediaListCollection.fetch({reset: true});
      var mediaListLayout = new ReleasesBlast.MediaListLayout();
      targetsTabLayout.mediaListRegion.show(mediaListLayout);
      
      var uploadMediaListView = new ReleasesBlast.UploadMediaListView({
        collection: mediaListCollection,
        pitchContactsCollection: self.module.pitchModel.get('contacts'),
        selectedMediaListsCollection: this.module.selectedMediaListsCollection
      });
      var selectedMediaListsView = new ReleasesBlast.SelectedMediaListsCompositeView({
        collection: this.module.selectedMediaListsCollection,
        pitchContactsCollection: self.module.pitchModel.get('contacts')
      });
      
      mediaListLayout.selectedMediaListsRegion.show(selectedMediaListsView);
      mediaListLayout.uploadMediaListRegion.show(uploadMediaListView);
    },
    pitch: function(params){
      this.module.releasesBlastHeader.set({ level: 4 });

      var pitchTabView = new this.module.PitchTabView({
        model: this.module.pitchModel,
        draftPitchModel: this.module.draftPitchModel,
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
      var emailPitchView = new ReleasesBlast.EmailPitchView({
        releaseModel: this.module.releaseModel,
        draftPitchModel: this.module.draftPitchModel,
        model: this.module.pitchModel
      });

      var twitterTargetsCollection = new Robin.Collections.TwitterTargetsCollection(
        twtrlandContacts
      );
      var twitterTargetsView = new ReleasesBlast.TwitterTargetsView({
        collection: twitterTargetsCollection
      });
      var twitterPitchView = new ReleasesBlast.TwitterPitchView({
        releaseModel: this.module.releaseModel,
        draftPitchModel: this.module.draftPitchModel,
        model: this.module.pitchModel
      });

      if (emailTargetsCollection.models.length > 0){
        pitchTabView.emailTargets.show(emailTargetsView);
        pitchTabView.emailPitch.show(emailPitchView);
      }
      
      if (twitterTargetsCollection.models.length > 0){
        pitchTabView.twitterTargets.show(twitterTargetsView);
        pitchTabView.twitterPitch.show(twitterPitchView);
      }
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
