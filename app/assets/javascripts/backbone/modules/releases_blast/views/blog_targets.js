Robin.module('ReleasesBlast', function(ReleasesBlast, App, Backbone, Marionette, $, _){

  ReleasesBlast.BlogTargetsView = Marionette.ItemView.extend({
    template: 'modules/releases_blast/templates/blog_targets',
    className: 'row',
    collection: Robin.Collections.SuggestedAuthors,
    initialize: function(){
      this.listenTo(this.collection, "reset", this.render);
    },
    templateHelpers: function(){
      return {
        suggestedAuthors: this.collection,
        wordMapper: this.wordMapper
      }
    },
    onRender: function() {
      // Get rid of that pesky wrapping-div.
      // Assumes 1 child element present in template.
      this.$el = this.$el.children();
      // Unwrap the element to prevent infinitely 
      // nesting elements during re-render.
      this.$el.unwrap();
      this.setElement(this.$el);
      this.$el.find('table').DataTable({
        "info": false,
        "searching": false,
        "lengthChange": false,
        "ordering": false,
        "columns": [
          { "width": "30%" },
          null,
          null,
          null,
          null,
          null
        ]
      });
    },
    wordMapper: function(word_count){
      if (word_count <= 150){
        return {label: "Very Short", tooltip: "<strong>150</strong> words or less"};
      }

      if (word_count < 520 && word_count > 150){
        return {
          label: "Short", 
          tooltip: "Between <strong>150</strong> and <strong>520</strong> words"
        };
      }

      if (word_count < 990 && word_count > 520){
        return {
          label: "Average", 
          tooltip: "Between <strong>520</strong> and <strong>990</strong> words"
        };
      }

      if (word_count < 1940 && word_count > 990){
        return {
          label: "Semi-long", 
          tooltip: "Between <strong>990</strong> and <strong>1940</strong> words"
        };
      }

      if (word_count < 4910 && word_count > 1940){
        return {
          label: "Long", 
          tooltip: "Between <strong>1940</strong> and <strong>4910</strong> words"
        };
      }

      if (word_count >= 4910){
        return {
          label: "Very long", 
          tooltip: "<strong>4910</strong> words or more"
        };
      }

      return "Not defined";
    }
  });
});
