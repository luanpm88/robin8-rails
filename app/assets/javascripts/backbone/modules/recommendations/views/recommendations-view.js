Robin.module('Recommendations', function(Recommendations, App, Backbone, Marionette, $, _){

  Recommendations.ItemView = Marionette.ItemView.extend({
    template: 'modules/recommendations/templates/recommendation',
    model: Robin.Models.Recommendation,
    className: 'recommendation',
    tagName: "div",

    initialize: function() {
        this.listenTo(this.model, "change", this.render);
    },

    events: {
        'click #like-content': 'likeContent',
        'click #dislike-content': 'dislikeContent',
        'click #share-content': 'shareContent',
        'click #view-content': 'viewContent'
    },

    onRender: function() {
      $(this.el).find(".recommendation-body" ).hover(
        function() {
            var overlayId = "#" + $(this).attr('id') + "-overlay";
            $(overlayId).show();
        }, function() {
             var overlayId = "#" + $(this).attr('id') + "-overlay";
             $(overlayId).hide();
        });
    },

    likeContent: function(e) {
        e.preventDefault();
        Robin.vent.trigger("LikeContent", this.model);
    },

    dislikeContent: function(e) {
        e.preventDefault();
        Robin.vent.trigger("DislikeContent", this.model);
    },

    shareContent: function(e) {
        e.preventDefault();
        Robin.vent.trigger("ShareContent", this.model);
    },

    viewContent: function(e) {
        e.preventDefault();
        var id = "#" + e.currentTarget.parentElement.id
        $(this.el).find(id).hide();
        window.open(this.model.attributes.link, '_blank');
        Robin.vent.trigger("ViewContent", this.model);
    }   
  });

  Recommendations.CollectionView = Marionette.CollectionView.extend({
    childView: Recommendations.ItemView,
    collection: Robin.Collections.Recommendations,
    className: 'recommendations',
    tagName: "div",
  });

  Recommendations.NoRecommendationsView = Marionette.CompositeView.extend({
    template: 'modules/recommendations/templates/no-recommendations'
  });

  Recommendations.LoadingView = Marionette.CompositeView.extend({
    template: 'modules/recommendations/templates/loading',
    className: 'recommendations-loading-container',
    onShow: function(){
      var opts = this._getOptions();
      this.$el.spin(opts);
    },
    onClose: function(){
      this.$el.spin(false);
    },
    _getOptions: function(){
      lines: 10 // The number of lines to draw
      length: 6 // The length of each line
      width: 2.5 // The line thickness
      radius: 7 // The radius of the inner circle
      corners: 1 // Corner roundness (0..1)
      rotate: 9 // The rotation offset
      direction: 1 // 1: clockwise, -1: counterclockwise
      color: '#000' // #rgb or #rrggbb
      speed: 1 // Rounds per second
      trail: 60 // Afterglow percentage
      shadow: false // Whether to render a shadow
      hwaccel: true // Whether to use hardware acceleration
      className: 'spinner' // The CSS class to assign to the spinner
      zIndex: 2e9 // The z-index (defaults to 2000000000)
      top: '0' // Top position relative to parent in px
      left: '0' // Left position relative to parent in px
    }
  });

  Recommendations.RecommendationsNavView = Marionette.CompositeView.extend({
     template: 'modules/recommendations/templates/recommendations-nav',
     events: {
        'click #content-recommendations': 'getContentRecommendations',
        'click #influence-recommendations': 'getInfluenceRecommendations',
        'click #both-recommendations': 'getBothRecommendations'
      },

      getContentRecommendations: function(e) {
        e.preventDefault();
        $(this.el).find('#content-recommendations').removeClass("active");
        Robin.vent.trigger("GetContentRecommendations");
      },

      getInfluenceRecommendations: function(e) {
        e.preventDefault();
        $(this.el).find('#content-recommendations').removeClass("active");
        Robin.vent.trigger("GetInfluenceRecommendations");
      },

      getBothRecommendations: function(e) {
        e.preventDefault();
        $(this.el).find('#content-recommendations').removeClass("active");
        Robin.vent.trigger("GetBothRecommendations");
      }
  });

  Recommendations.NewRecommendationsView = Marionette.CompositeView.extend({
    template: 'modules/recommendations/templates/new-recommendations',
    
      events: {
        'click #insert-user-tastes': 'InsertUserTastes',
      },

      onRender: function() {

        Robin.currentUser.attributes["topics"] = "";

        $(this.el).find('#topics-select').select2({
          multiple: true,
          tags: true,
          minimumInputLength: 1,
          ajax: {
            url: '/autocompletes/topics',
            dataType: 'json',
            data: function(term, page) { 
              return { term: term } 
            },
            results: function(data, page) { 
              Robin.currentUser.attributes["topics"] = $("#topics-select").val();
              return { results: data }; 
            }
          }
        }).on("select2-selecting", function(e) {
          Robin.currentUser.attributes["topics"] = $("#topics-select").val();
        }).on("select2-removed", function(e) {
          Robin.currentUser.attributes["topics"] = $("#topics-select").val();
        });

        $(this.el).find('#category-select').change(function() {
          Robin.currentUser.attributes["category"] = $('#category-select').val();
        });

      },

      InsertUserTastes: function(e) {
        e.preventDefault();
        Robin.vent.trigger("InsertUserTastes");
      }

  });

  

});
