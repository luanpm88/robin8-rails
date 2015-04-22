Robin.module('Recommendations', function(Recommendations, App, Backbone, Marionette, $, _){

  Recommendations.Controller = Marionette.Controller.extend({

    initialize: function () {
      this.module = Robin.module("Recommendations");
    },
    index: function(){
      var recommendationView = new Recommendations.ToBeDesignedView()
      Robin.layouts.main.getRegion('content').show(recommendationView);
    }

  });
});