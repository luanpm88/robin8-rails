Robin.module('ReleasesBlast', function(ReleasesBlast, App, Backbone, Marionette, $, _){

  ReleasesBlast.SearchCriteriaView = Marionette.ItemView.extend({
    template: 'modules/releases_blast/templates/search-criteria',
    tagName: "div",
    className: "panel panel-success"
  });
});
