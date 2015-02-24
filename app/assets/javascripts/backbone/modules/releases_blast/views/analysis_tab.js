Robin.module('ReleasesBlast', function(ReleasesBlast, App, Backbone, Marionette, $, _){

  ReleasesBlast.AnalysisTabView = Marionette.ItemView.extend({
    template: 'modules/releases_blast/templates/analysis-tab',
    className: 'row',
    events: {
      'click button.btn': 'openTargetsTab'
    },
    onRender: function () {
      // Get rid of that pesky wrapping-div.
      // Assumes 1 child element present in template.
      this.$el = this.$el.children();
      // Unwrap the element to prevent infinitely 
      // nesting elements during re-render.
      this.$el.unwrap();
      this.setElement(this.$el);
      
      $('#release-category').editable();

      $('#release-topics').editable({
        source: [
              {id: 'ai', text: 'Artificial Intelligence'},
              {id: 'dm', text: 'Data Mining'},
              {id: 'ml', text: 'Machine Learning'},
              {id: 'nlp', text: 'Natural Language Processing'},
              {id: 'db', text: 'Dublin'},
              {id: 'ln', text: 'London'},
              {id: 'api', text: 'API'}
           ],
        select2: {
           multiple: true
        }
      });
    },
    openTargetsTab: function(){
      ReleasesBlast.controller.targets();
    }
  });
});
