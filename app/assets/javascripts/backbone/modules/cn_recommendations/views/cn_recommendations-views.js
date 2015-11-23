Robin.module('CnRecommendations', function(CnRecommendations, App, Backbone, Marionette, $, _){
  CnRecommendations.ItemView = Marionette.ItemView.extend({
    template: "modules/cn_recommendations/templates/cn_recommendation",
    model: Robin.Models.CnRecommendtaion,
    className: "cn_recommendation",
    tagName: "div",

    initialize: function(){
      this.listenTo(this.model, "change", this.render);
    },

    onRender: function(){
    },
  });

  CnRecommendations.CollectionView = Marionette.CollectionView.extend({
    childView: CnRecommendations.ItemView,
    collection: Robin.Collections.CnRecommendations,
    className: "cn_recommendations",
    tagName: "div",

    onRender: function(){
      var page = this.collection.page;
      $(window).scroll(function(){
        if($(window).scrollTop() + $(window).height() == $(document).height()){
          $(window).unbind("scroll");
          var nextPage = page + 1;
          if($('#more-recommendations').not(':visible')){$('#more-recommendations').show();}
          $("#more-recommendation-row").before("<div id='more-recommendations-container-" + nextPage + "' class='more-recommendations'></div>");  
          Robin.vent.trigger("getNextPage", nextPage);
        } 
      })
    }
  });
});