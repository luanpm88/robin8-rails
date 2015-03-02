Robin.module('ReleasesBlast', function(ReleasesBlast, App, Backbone, Marionette, $, _){

  ReleasesBlast.InfluencerView = Marionette.ItemView.extend({
    template: 'modules/releases_blast/templates/influencer-item',
    tagName: "tr",
    model: Robin.Models.Influencer,
    templateHelpers: function(){
      return {
        user: this.model
      }
    }
  });
});
