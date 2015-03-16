Robin.module('ReleasesBlast', function(ReleasesBlast, App, Backbone, Marionette, $, _){

  ReleasesBlast.TopMenuView = Marionette.ItemView.extend({
    template: 'modules/releases_blast/templates/top-menu/top-menu',
    className: 'breadcrumb breadcrumb-arrow blast-steps',
    tagName: 'ul',
    model: Robin.Models.ReleasesBlastHeader,
    ui: {
      startHeaderTab: "#blast-home-link",
      analysisHeaderTab: "#blast-analysis-link",
      targetsHeaderTab: "#blast-targets-link",
      pitchHeaderTab: "#blast-pitch-link"
    },
    modelEvents: {
      "change": "render"
    },
    events: {
      'click @ui.startHeaderTab': "startHeaderTabClicked",
      'click @ui.analysisHeaderTab': "analysisHeaderTabClicked",
      'click @ui.targetsHeaderTab': "targetsHeaderTabClicked",
      'click @ui.pitchHeaderTab': "pitchHeaderTabClicked"
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
    },
    startHeaderTabClicked: function(e){
      e.preventDefault();
      
      Robin.vent.trigger('start:tab:clicked');
    },
    analysisHeaderTabClicked: function(e){
      e.preventDefault();
      
      Robin.vent.trigger('analysis:tab:clicked');
    },
    targetsHeaderTabClicked: function(e){
      e.preventDefault();
      
      Robin.vent.trigger('targets:tab:clicked');
    },
    pitchHeaderTabClicked: function(e){
      e.preventDefault();
      
      Robin.vent.trigger('pitch:tab:clicked');
    }
  });
});
