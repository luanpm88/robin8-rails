Robin.module('ReleasesBlast', function(ReleasesBlast, App, Backbone, Marionette, $, _){
  var NoChildrenView = Marionette.ItemView.extend({
    template: 'modules/releases_blast/templates/stories/empty_view'
  });
  
  ReleasesBlast.StoryItemView = Marionette.ItemView.extend({
    template: 'modules/releases_blast/templates/stories/_story',
    tagName: 'li',
    templateHelpers: function () {
      if (Robin.currentUser.get('locale') == 'zh'){
        return description_line = s.truncate(this.model.get('description'), 30);
      } else {
        return description_line = s.prune(this.model.get('title'), 55);
      }
    }
  });

  ReleasesBlast.StoriesList = Marionette.CollectionView.extend({
    childView: ReleasesBlast.StoryItemView,
    emptyView: NoChildrenView,
    tagName: "ul"
  });
});
