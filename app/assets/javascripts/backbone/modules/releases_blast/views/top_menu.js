Robin.module('ReleasesBlast', function(ReleasesBlast, App, Backbone, Marionette, $, _){

  ReleasesBlast.TopMenuView = Marionette.ItemView.extend({
    template: 'modules/releases_blast/templates/top-menu',
    className: 'row',
    templateHelpers: function () {
      return this.options;
    },
    onRender: function () {
      // Get rid of that pesky wrapping-div.
      // Assumes 1 child element present in template.
      this.$el = this.$el.children();
      // Unwrap the element to prevent infinitely 
      // nesting elements during re-render.
      this.$el.unwrap();
      this.setElement(this.$el);
    }
  });
});
