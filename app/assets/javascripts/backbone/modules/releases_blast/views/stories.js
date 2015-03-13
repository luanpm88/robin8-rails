Robin.module('ReleasesBlast', function(ReleasesBlast, App, Backbone, Marionette, $, _){
  var NoChildrenView = Marionette.ItemView.extend({
    template: 'modules/releases_blast/templates/stories/empty_view'
  });
  
  ReleasesBlast.StoryItemView = Marionette.ItemView.extend({
    template: 'modules/releases_blast/templates/stories/_story',
    tagName: 'li'
  });

  ReleasesBlast.StoriesList = Marionette.CollectionView.extend({
    childView: ReleasesBlast.StoryItemView,
    emptyView: NoChildrenView,
    tagName: "ul"
  });
});
