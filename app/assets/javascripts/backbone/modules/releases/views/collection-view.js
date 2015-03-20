Robin.module('Releases', function(Releases, App, Backbone, Marionette, $, _){

  Releases.CollectionView = Marionette.CollectionView.extend({
    tagName: 'ul',
    className: 'thumbnails',
    initialize: function(){
      $(window).on("resize",this.arrangeReleases);
    },
    onRenderCollection: function(){
      this.arrangeReleases();
    },
    arrangeReleases: function(){
      // needs to be refactored
      var listWidth = $('.thumbnails').width();
      if (listWidth >= 799) {
        releasesPerRow = 3;
      } else if (listWidth >= 575) {
        releasesPerRow = 2;
      } else {
        releasesPerRow = 1;
      }
      if (releasesPerRow != 1) {
        var allReleases = $('.thumbnail.release-item').toArray();
        var arrays = [], size = releasesPerRow;
        while (allReleases.length > 0)
          arrays.push(allReleases.splice(0, size));
        $.each(arrays, function(index, row) {
          var highest = 0;
          $.each(row, function(item, value) {
            $(value).height("auto");
            if ($(value).height() > highest) highest = $(value).height();
          });
          $(row).height(highest);
        });
      }
    },
  });
});