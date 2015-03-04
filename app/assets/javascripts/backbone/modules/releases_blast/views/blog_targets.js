Robin.module('ReleasesBlast', function(ReleasesBlast, App, Backbone, Marionette, $, _){

  ReleasesBlast.BlogTargetsCompositeView = Marionette.CompositeView.extend({
    template: 'modules/releases_blast/templates/blog-targets',
    childView: ReleasesBlast.AuthorView,
    childViewContainer: "tbody",
    collection: Robin.Collections.SuggestedAuthors,
    childViewOptions: function() {
      return {
        releaseModel: this.releaseModel,
        pitchContactsCollection: this.pitchContactsCollection
      };
    },
    initialize: function(options){
      this.releaseModel = options.releaseModel;
      this.pitchContactsCollection = options.pitchContactsCollection
    },
    onRender: function() {
      this.$el.find('table').DataTable({
        "info": false,
        "searching": false,
        "lengthChange": false,
        "ordering": false,
        "pageLength": 5,
        "columns": [
          { "width": "30%" },
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
