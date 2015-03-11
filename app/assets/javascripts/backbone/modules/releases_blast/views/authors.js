Robin.module('ReleasesBlast', function(ReleasesBlast, App, Backbone, Marionette, $, _){

  ReleasesBlast.AuthorsCompositeView = Marionette.CompositeView.extend({
    template: 'modules/releases_blast/templates/authors',
    childView: ReleasesBlast.AuthorView,
    childViewContainer: "tbody",
    collection: Robin.Collections.Authors,
    childViewOptions: function() {
      return this.options;
    },
    onRender: function() {
      this.initDataTable();
    },
    initDataTable: function(){
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
          null
        ]
      });
    }
  });
});
