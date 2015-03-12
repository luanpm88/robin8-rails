Robin.module('ReleasesBlast', function(ReleasesBlast, App, Backbone, Marionette, $, _){

  ReleasesBlast.StartTabView = Marionette.ItemView.extend({
    template: 'modules/releases_blast/templates/start_tab/show',
    collectionEvents: {
      "reset": "render"
    },
    ui: {
      releasesSelect: 'select',
      analyzeButton: '#analyze'
    },
    events: {
      'change @ui.releasesSelect': 'releasesSelectChanged',
      'click @ui.analyzeButton': 'analyzeButtonClicked'
    },
    serializeData: function(){
      return {
        "items": this.collection.models
      }
    },
    releasesSelectChanged: function(e){
      if(this.ui.releasesSelect.val() == -2){
        this.openNewRelease();
      } else if (this.ui.releasesSelect.val() == -1){
        this.ui.analyzeButton.prop('disabled', true);
      } else {
        this.ui.analyzeButton.prop('disabled', false);
      }
    },
    openNewRelease: function(){
      Backbone.history.navigate('releases', {trigger: true});
    },
    analyzeButtonClicked: function(e){
      e.preventDefault();
      
      var selectValue = this.ui.releasesSelect.val();
      if ((selectValue != -1) || (selectValue != -2)){
        this.analyzeRelease(parseInt(selectValue));
      }
    },
    analyzeRelease: function(releaseId){
      var the_release = this.collection.findWhere({id: releaseId});
      ReleasesBlast.controller.analysis({releaseModel: the_release});
    }
  });
});
