Robin.module('ReleasesBlast', function(ReleasesBlast, App, Backbone, Marionette, $, _){

  ReleasesBlast.SocialTargetsView = Marionette.ItemView.extend({
    template: 'modules/releases_blast/templates/social_targets',
    className: 'row',
    collection: Robin.Collections.Influencers,
    initialize: function(){
      this.listenTo(this.collection, "reset", this.render);
    },
    templateHelpers: function(){
      return {
        influencers: this.collection
      }
    },
    onRender: function () {
      // Get rid of that pesky wrapping-div.
      // Assumes 1 child element present in template.
      this.$el = this.$el.children();
      // Unwrap the element to prevent infinitely 
      // nesting elements during re-render.
      this.$el.unwrap();
      this.setElement(this.$el);
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
