Robin.module('ReleasesBlast', function(ReleasesBlast, App, Backbone, Marionette, $, _){

  ReleasesBlast.AuthorInspectLayout = Marionette.LayoutView.extend({
    template: 'modules/releases_blast/templates/author-inspect-layout',
    regions: {
      statsRegion: '#author-stats',
      recentStoriesRegion: '#author-recent-stories',
      relatedStoriesRegion: '#author-related-stories'
    },
    className: 'modal-dialog'
  });
});

