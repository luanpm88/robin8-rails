Robin.module('ReleasesBlast', function(ReleasesBlast, App, Backbone, Marionette, $, _){

  ReleasesBlast.StartTabView = Marionette.ItemView.extend({
    template: 'modules/releases_blast/templates/start_tab/show',
    collectionEvents: {
      "reset": "render"
    },
    ui: {
      releasesSelect: 'select',
      analyzeButton: '#analyze',
      alertInfo: '#writing-pr-info'
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
      var view = this;
      if (Robin.releaseForBlast != undefined && this.collection.length > 0){
        view.analyzeRelease(parseInt(Robin.releaseForBlast));
        Robin.releaseForBlast = undefined;
      }
    },
    standardPressRelease: {
      min_characters_count: 1000,
      min_words_count: 200,
      min_sentences_count: 7,
      min_average_characters_count_per_word: 4,
      min_average_words_count_per_sentence: 12
    },
    releasesSelectChanged: function(e){
      if (Robin.user.get('can_create_smart_release') != true) {
        this.ui.analyzeButton.addClass('disabled-unavailable');
      } else {
        this.ui.analyzeButton.removeClass('disabled-unavailable');
      }
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
      if (Robin.user.get('can_create_smart_release') != true) {
        $.growl({message: "You don't have available smart-releases!"},
          {
            type: 'info'
          });
      } else {        
        var selectValue = this.ui.releasesSelect.val();
        if ((selectValue != -1) || (selectValue != -2)){
          this.analyzeRelease(parseInt(selectValue));
        }
      }
    },
    analyzeRelease: function(releaseId){
      var the_release = this.collection.findWhere({id: releaseId});
      
      if (the_release.get('characters_count') > this.standardPressRelease.min_characters_count &&
        the_release.get('words_count') > this.standardPressRelease.min_words_count &&
        the_release.get('sentences_count') > this.standardPressRelease.min_sentences_count &&
        the_release.get('average_characters_count_per_word') >
          this.standardPressRelease.min_average_characters_count_per_word &&
        the_release.get('average_words_count_per_sentence') >
          this.standardPressRelease.min_average_words_count_per_sentence){
          
        ReleasesBlast.controller.analysis({releaseModel: the_release});
      } else {
        $.growl({
          message: "Your Press Release is not standard, we can't analyze it!"
        },{
          type: 'danger'
        });
        this.ui.alertInfo.show();
      }
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
      
      this.on("close", function(){ 
        Robin.commands.removeHandler("goToAnalysisTab");
      });
    }
  });
});
