Robin.module('ReleasesBlast', function(ReleasesBlast, App, Backbone, Marionette, $, _){
  ReleasesBlast.AuthorStoriesCompositeView = Marionette.ItemView.extend({
    template: 'modules/releases_blast/templates/author-stories',
    collection: Robin.Collections.Stories,
    childView: ReleasesBlast.StoryItemView,
    childViewContainer: "ul"
  });
});
