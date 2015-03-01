Robin.module('ReleasesBlast', function(ReleasesBlast, App, Backbone, Marionette, $, _){

  ReleasesBlast.AuthorView = Marionette.ItemView.extend({
    template: 'modules/releases_blast/templates/author-item',
    tagName: "tr",
    model: Robin.Models.Author,
    templateHelpers: function(){
      return {
        author: this.model,
        wordMapper: this.wordMapper
      }
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
