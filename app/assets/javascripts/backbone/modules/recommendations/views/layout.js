Robin.module('Recommendations', function(Recommendations, App, Backbone, Marionette, $, _){
  Recommendations.Layout = Marionette.LayoutView.extend({
    template: 'modules/recommendations/templates/layout',
      regions: {
        nav: '#recommendations-nav',
        main: '#recommendations-container'
    }
  });
});
