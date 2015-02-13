// NewsRoomsCollectionView
Robin.module('Newsroom', function(Newsroom, App, Backbone, Marionette, $, _){

  Newsroom.CollectionView = Marionette.CollectionView.extend({
    tagName: 'ul',
    className: 'thumbnails list-unstyled newsrooms'
  });
});
