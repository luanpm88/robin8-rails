Robin.module('ReleasesBlast', function(ReleasesBlast, App, Backbone, Marionette, $, _){

  ReleasesBlast.SocialTargetsCompositeView = Marionette.CompositeView.extend({
    template: 'modules/releases_blast/templates/social-targets',
    childView: ReleasesBlast.InfluencerView,
    childViewContainer: "tbody",
    childViewOptions: function() {
      return this.options;
    },
    onRender: function () {
      this.initDataTable();
    },
    initDataTable: function(){
      this.$el.find('table').DataTable({
        "info": false,
        "searching": false,
        "lengthChange": false,
        "order": [[ 4, 'desc' ]],
        "pageLength": 5,
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
