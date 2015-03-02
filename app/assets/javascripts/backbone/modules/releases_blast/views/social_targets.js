Robin.module('ReleasesBlast', function(ReleasesBlast, App, Backbone, Marionette, $, _){

  ReleasesBlast.SocialTargetsCompositeView = Marionette.CompositeView.extend({
    template: 'modules/releases_blast/templates/social-targets',
    collection: Robin.Collections.Influencers,
    childView: ReleasesBlast.InfluencerView,
    childViewContainer: "tbody",
    onRender: function () {
      this.$el.find('table').DataTable({
        "info": false,
        "searching": false,
        "lengthChange": false,
        "order": [[ 4, 'desc' ]],
        "columns": [
          { "width": "30% !important" },
          null,
          null,
          null,
          null,
          null,
          null
        ]
      });
    }
  });
});
