Robin.module('ReleasesBlast', function(ReleasesBlast, App, Backbone, Marionette, $, _){

  ReleasesBlast.SearchLayout = Marionette.LayoutView.extend({
    template: 'modules/releases_blast/templates/search',
    regions: {
      searchCriteriaRegion: '#search-criteria',
      searchResultRegion: '#search-result'
    }
  });
});

