Robin.module('ReleasesBlast', function(ReleasesBlast, App, Backbone, Marionette, $, _){
  ReleasesBlast.StoryItemView = Marionette.ItemView.extend({
    template: 'modules/releases_blast/templates/_story',
    model: Robin.Models.Story
  });
});
