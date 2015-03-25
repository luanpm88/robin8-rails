Robin.module('Releases', function(Releases, App, Backbone, Marionette, $, _){

  Releases.CollectionView = Marionette.CollectionView.extend({
    tagName: 'ul',
    className: 'releases-view',
    initialize: function(){
      $(window).on("resize",this.arrangeReleases);
    },
    onRenderCollection: function(){
      if ($('.releases-view').width() != null) {
        this.arrangeReleases();
      }
    },
    onShow: function(){
      this.arrangeReleases();
    },
    arrangeReleases: function(){
      // needs to be refactored
      var listWidth = $('.releases-view').width();
      var releasesPerRow = Math.floor( listWidth / 360 );
      if (releasesPerRow != 1) {
        var allReleases = $('.release-item').toArray();
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