Robin.module('ReleasesBlast', function(ReleasesBlast, App, Backbone, Marionette, $, _){
  ReleasesBlast.StoryItemView = Marionette.ItemView.extend({
    template: 'modules/releases_blast/templates/stories/_story',
    tagName: 'li'
  });

  ReleasesBlast.StoriesList = Marionette.CollectionView.extend({
    childView: ReleasesBlast.StoryItemView,
    tagName: "ul",
  });
});
