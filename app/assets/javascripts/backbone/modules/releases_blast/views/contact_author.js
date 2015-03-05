Robin.module('ReleasesBlast', function(ReleasesBlast, App, Backbone, Marionette, $, _){
  ReleasesBlast.ContactAuthorFormView = Marionette.ItemView.extend({
    template: 'modules/releases_blast/templates/contact-author/contact-form',
    model: Robin.Models.Author,
    className: "modal-dialog",
    ui: {
      summarizeSlider: "#slider"
    },
    initialize: function(options){
      this.releaseModel = options.releaseModel;
      this.initSlider();
    },
    initSlider: function(){
      console.log(this.ui.summarizeSlider);
//      this.ui.summarizeSlider.slider();
    }
  });
});
