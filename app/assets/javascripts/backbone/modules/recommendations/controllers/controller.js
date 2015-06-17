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
    },

    index: function(recommendationType){
        Robin.layouts.main.content.show(Recommendations.layout);
        this.showRecommendations("content");
    },

    showRecommendations: function(recommendationType){
        var module = this.module;
        this.collection = new Robin.Collections.Recommendations();

        this.collection.fetch({
            success: function (recommendations) {
                console.log(recommendations);
                if(recommendations.length > 0){
                    var recommendationsView = new Recommendations.CollectionView({ collection : recommendations });
                    var navRecommendationsView = new Recommendations.RecommendationsNavView();
                    module.layout.main.show(recommendationsView);
                    module.layout.nav.show(navRecommendationsView);
                }else{
                    var recommendationView = new Recommendations.NewRecommendationsView();
                    module.layout.main.show(recommendationView);
                }
            },
            data: { type : recommendationType },
            processData: true
        });
    },

    showRecommendationsType: function(recommendationType){
        var module = this.module;

        this.collection.fetch({
            success: function (recommendations) {
                if(recommendations.length > 0){
                    var recommendationsView = new Recommendations.CollectionView({ collection : recommendations });
                    module.layout.main.show(recommendationsView);
                }else{
                    var noRecommendationsView = new Recommendations.NoRecommendationsView();
                    module.layout.main.show(noRecommendationsView);
                }              
            },
            data: { type : recommendationType },
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
   
        // $('#share-modal').modal({ keyboard: false });
        var id = recommendation.attributes.id; 
        var topics = recommendation.attributes.topics.slice(0, 6).join();
        var categories = recommendation.attributes.categories;

        wripl._track(Robin.currentUser.attributes['id'], id, "SHARE", "", topics, categories);
    },

    LikeContent: function(recommendation){
        var shortenedTitle = $.trim(recommendation.attributes.title).split(" ").slice(0, 6).join(" ") + " ... ";
        $.growl(shortenedTitle + " Increased in relevence", {type: 'success'});
        var id = recommendation.attributes.id; 
        var topics = recommendation.attributes.topics.slice(0, 6).join();
        var categories = recommendation.attributes.categories;
        wripl._track(Robin.currentUser.attributes['id'], id, "LIKE", "", topics, categories);
    },

    DislikeContent: function(recommendation){
        var shortenedTitle = $.trim(recommendation.attributes.title).split(" ").slice(0, 6).join(" ") + " ... ";
        $.growl(shortenedTitle + " Removed", {type: 'success'});
        this.collection.remove(recommendation);
        var id = recommendation.attributes.id; 
        var topics = recommendation.attributes.topics.slice(0, 6).join();
        var categories = recommendation.attributes.categories;
        wripl._track(Robin.currentUser.attributes['id'], id, "DISLIKE", "", topics, categories);
    },

    GetContentRecommendations: function(){
        this.module.controller.showRecommendationsType("content");
    },

    GetInfluenceRecommendations: function(){
        this.module.controller.showRecommendationsType("influence");
    },

    GetBothRecommendations: function(){
        this.module.controller.showRecommendationsType("both");
    },

    

  });
});
