Robin.module('ReleasesBlast', function(ReleasesBlast, App, Backbone, Marionette, $, _){

  ReleasesBlast.TargetsTabView = Marionette.ItemView.extend({
    template: 'modules/releases_blast/templates/targets-tab',
    className: 'row',
    events: {
      "click #next-step": "openPitchTab"
    },
    onRender: function () {
      // Get rid of that pesky wrapping-div.
      // Assumes 1 child element present in template.
      this.$el = this.$el.children();
      // Unwrap the element to prevent infinitely 
      // nesting elements during re-render.
      this.$el.unwrap();
      this.setElement(this.$el);
    },
    openPitchTab: function(){
      ReleasesBlast.controller.pitch();
    }
  });
});
