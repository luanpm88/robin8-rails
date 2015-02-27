Robin.module('ReleasesBlast', function(ReleasesBlast, App, Backbone, Marionette, $, _){

  ReleasesBlast.SocialTargetsView = Marionette.ItemView.extend({
    template: 'modules/releases_blast/templates/social_targets',
    className: 'row',
    initialize: function(options){
      this.influencers = options.influencers;
    },
    templateHelpers: function(){
      return {
        influencers: this.influencers
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
        "ordering": false,
        "columns": [
          { "width": "50%" },
          { "width": "5%" },
          { "width": "12%" },
          { "width": "12%" },
          { "width": "12%" },
          { "width": "5%" },
          { "width": "5%" },
        ]
      });
    }
  });
});
