Robin.module('ReleasesBlast', function(ReleasesBlast, App, Backbone, Marionette, $, _){

  ReleasesBlast.StartTabView = Marionette.ItemView.extend({
    template: 'modules/releases_blast/templates/start-tab',
    collection: Robin.Collections.Releases,
    collectionEvents: {
      "reset": "render"
    },
    events: {
      'change .form-control': 'selectChanged',
      'click #analyze': 'analyzeRelease' 
    },
    serializeData: function(){
      return {
        "items": this.collection.models
      }
    },
    selectChanged: function(e){
      if($(e.currentTarget).val() == -2){
        this.openNewRelease();
      }
    },
    openNewRelease: function(){
      Backbone.history.navigate('releases', {trigger: true});
    },
    analyzeRelease: function(){
      var selected_release = parseInt($('select.form-control').val());
      if ((selected_release != -1) || (selected_release != -2)){
        var the_release = this.collection.findWhere({id: selected_release});
        ReleasesBlast.controller.analysis({release_id: the_release.id});
      }
    }
  });
});
