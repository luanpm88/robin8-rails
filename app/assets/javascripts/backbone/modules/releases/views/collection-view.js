Robin.module('Releases', function(Releases, App, Backbone, Marionette, $, _){

  Releases.CollectionView = Marionette.CollectionView.extend({
    tagName: 'ul',
    className: 'thumbnails'
    // className: 'thumbnails list-unstyled releases'
  });
});
