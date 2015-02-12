// NewsRoomsCollectionView
Robin.module('Newsroom', function(Newsroom, App, Backbone, Marionette, $, _){

  Newsroom.CollectionView = Marionette.CompositeView.extend({
    template: 'modules/news_room/templates/collection_view',
    childViewContainer: ".newsrooms"
    // tagName: 'ul',
    // className: 'thumbnails list-unstyled newsrooms'
  });
});
