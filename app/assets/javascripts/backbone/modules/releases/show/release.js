Robin.module('Releases.Show', function(Show, App, Backbone, Marionette, $, _){

  Show.ReleaseItem = Backbone.Marionette.ItemView.extend({
    template: 'modules/releases/show/templates/release-item',

    tagName: "div",

    model: Robin.Models.Release,

    serializeData : function() {
      window.$thisModel = this.model;
      return {
        text: 'text'
      };
    },

    events: {
      'click #edit-release': 'editRelease',
    },

    editRelease: function(e) {
    },
  });

  Show.ReleasesComposite = Backbone.Marionette.CompositeView.extend({
    template: "modules/releases/show/templates/releases-composite",
    childView: Show.ReleaseItem,
    childViewContainer: "ul",
    initialize: function() {
      // this.collection.fetch();
      this.collection.add(new Robin.Models.Release());
    }
  });

});