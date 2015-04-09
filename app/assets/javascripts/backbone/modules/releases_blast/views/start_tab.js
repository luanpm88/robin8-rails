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
    onRender: function(){
      // if (!Robin.user.get('can_create_smart_release')) {
      //   $('.alert-danger').show();
      // }
      var view = this;
      if (Robin.releaseForBlast != undefined && this.collection.length > 0){
        view.analyzeRelease(parseInt(Robin.releaseForBlast));
        Robin.releaseForBlast = undefined;
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
      Robin.newReleaseFromDashboard = true;
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
    },
    initialize: function(options){
      var self = this;
      Robin.commands.setHandler("goToAnalysisTab", function(){
        if (self.ui.analyzeButton.prop('disabled') === false){
          var selectValue = self.ui.releasesSelect.val();
          if ((selectValue != -1) || (selectValue != -2)){
            self.analyzeRelease(parseInt(selectValue));
          }
        }
      });
    }
  });
});
