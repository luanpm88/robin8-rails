Robin.module('ReleasesBlast', function(ReleasesBlast, App, Backbone, Marionette, $, _){

  ReleasesBlast.TopMenuView = Marionette.ItemView.extend({
    template: 'modules/releases_blast/templates/top-menu/top-menu',
    className: 'breadcrumb breadcrumb-arrow blast-steps',
    tagName: 'ul',
    model: Robin.Models.ReleasesBlastHeader,
    modelEvents: {
      "change": "render"
    },
    attributes: {
      "role": "tablist"
    },
    templateHelpers: function () {
      return {
        "pitchContactsCollection": this.pitchContactsCollection
      };
    },
    initialize: function(options){
      this.pitchContactsCollection = options.pitchContactsCollection;
      this.pitchContactsCollection.bind('add remove', this.render, this);
    }
  });
});
