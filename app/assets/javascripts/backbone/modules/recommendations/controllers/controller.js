Robin.module('Recommendations', function(Recommendations, App, Backbone, Marionette, $, _){

  Recommendations.Controller = Marionette.Controller.extend({

    initialize: function () {
        var self = this;
        self.module = Robin.module("Recommendations");
        Robin.vent.on("InsertUserTastes", function (topics, category) {
            self.InsertUserTastes(topics, category);
        });

        Robin.vent.on("ViewContent", function (recommendation) {
            self.ViewContent(recommendation);
        });

        Robin.vent.on("ShareContent", function (recommendation) {
            self.ShareContent(recommendation);
        });

        Robin.vent.on("LikeContent", function (recommendation) {
            self.LikeContent(recommendation);
        });

        Robin.vent.on("DislikeContent", function (recommendation) {
            self.DislikeContent(recommendation);
        });

        Robin.vent.on("GetContentRecommendations", function () {
            self.GetContentRecommendations();
        });

        Robin.vent.on("GetInfluenceRecommendations", function () {
            self.GetInfluenceRecommendations();
        });

        Robin.vent.on("GetBothRecommendations", function () {
            self.GetBothRecommendations();
        });
        Robin.vent.on("GetNextPage", function (page, recommendationType) {
            self.GetNextPage(page, recommendationType);
        });
    },

    index: function(recommendationType){
        Robin.layouts.main.content.show(Recommendations.layout);
        this.showRecommendations(recommendationType);
    },

    showRecommendations: function(recommendationType){
        var module = this.module;
        this.collection = new Robin.Collections.Recommendations();

        this.collection.fetch({
            success: function (recommendations) {
                recommendations.page = 0;
                recommendations.recommendationType = recommendationType;
                if(recommendations.length > 0){

                    var navRecommendationsView = new Recommendations.RecommendationsNavView();
                    var recommendationsView = new Recommendations.CollectionView({ collection : recommendations });
                    
                    module.layout.nav.show(navRecommendationsView);
                    module.layout.main.show(recommendationsView);
                }else{
                    var recommendationView = new Recommendations.NewRecommendationsView();
                    module.layout.main.show(recommendationView);
                }
            },
            data: { type : recommendationType, page: 0 },
            processData: true
        });
    },

    showRecommendationsType: function(recommendationType){
        var module = this.module;   

        this.collection.fetch({
            success: function (recommendations) {
                    
                recommendations.page = 0;
                recommendations.recommendationType = recommendationType;

                if(recommendations.length > 0){
                    var recommendationsView = new Recommendations.CollectionView({ collection : recommendations });
                    module.layout.main.show(recommendationsView);
                }else{
                    var noRecommendationsView = new Recommendations.NoRecommendationsView();
                    module.layout.main.show(noRecommendationsView);
                }              
            },
            data: { type : recommendationType, page: 0 },
            processData: true
        });
    },

    InsertUserTastes: function (topics, category) {
        var module = this.module;
        var loadingView = new Recommendations.LoadingView();
        module.layout.main.show(loadingView);
        wripl._track(Robin.currentUser.attributes['id'], 0, "INSERT", "", topics, category);
        this.module.controller.showRecommendations();
    },

    ViewContent: function(recommendation){
        var id = recommendation.attributes.id; 
        var topics = recommendation.attributes.topics.slice(0, 6).join();
        var categories = recommendation.attributes.categories;
        wripl._track(Robin.currentUser.attributes['id'], id, "VIEW", "", topics, categories);
    },

    ShareContent: function(recommendation){
        
        var id = recommendation.attributes.id; 
        var author_id = recommendation.attributes.author_id; 
        var topics = recommendation.attributes.topics.slice(0, 6).join();
        var categories = recommendation.attributes.categories;

        wripl._track(Robin.currentUser.attributes['id'], author_id, "INFLUENCE", "", topics, categories);
        wripl._track(Robin.currentUser.attributes['id'], id, "SHARE", "", topics, categories);
    },

    LikeContent: function(recommendation){
        var shortenedTitle = $.trim(recommendation.attributes.title).split(" ").slice(0, 6).join(" ") + " ... ";
        $.growl(shortenedTitle + " Increased in relevence", {type: 'success'});

        var id = recommendation.attributes.id; 
        var author_id = recommendation.attributes.author_id; 
        var topics = recommendation.attributes.topics.slice(0, 6).join();
        var categories = recommendation.attributes.categories;

        wripl._track(Robin.currentUser.attributes['id'], author_id, "INFLUENCE", "", topics, categories);
        wripl._track(Robin.currentUser.attributes['id'], id, "LIKE", "", topics, categories);
    },

    DislikeContent: function(recommendation){
        var shortenedTitle = $.trim(recommendation.attributes.title).split(" ").slice(0, 6).join(" ") + " ... ";
        $.growl(shortenedTitle + " Decreased in relevence", {type: 'success'});
        var id = recommendation.attributes.id; 
        var topics = recommendation.attributes.topics.slice(0, 6).join();
        var categories = recommendation.attributes.categories;
        wripl._track(Robin.currentUser.attributes['id'], id, "DISLIKE", "", topics, categories);
    },

    GetContentRecommendations: function(){
        this.module.controller.showRecommendationsType("CONTENT");
    },

    GetInfluenceRecommendations: function(){
        this.module.controller.showRecommendationsType("INFLUENCE");
    },

    GetBothRecommendations: function(){
        this.module.controller.showRecommendationsType("BOTH");
    },

    GetNextPage: function(page, recommendationType){
        var module = this.module;
        this.collection = new Robin.Collections.Recommendations();
        this.collection.fetch({
            success: function (recommendations) {

                recommendations.page = page;
                recommendations.recommendationType = recommendationType;

                var recommendationsView = new Recommendations.CollectionView({ collection : recommendations });
                module.layout.addRegion("more", "#more-recommendations-container-" + page);
                module.layout.more.show(recommendationsView);  
            },
            data: { type : recommendationType, page: page },
            processData: true
        });
    }
  });
});
