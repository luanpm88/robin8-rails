Robin.module('ReleasesBlast', function(ReleasesBlast, App, Backbone, Marionette, $, _){

  ReleasesBlast.AuthorView = Marionette.ItemView.extend({
    template: 'modules/releases_blast/templates/author-item',
    tagName: "tr",
    model: Robin.Models.Author,
    events: {
      "click .inspect":         "openModal",
      "click a.btn-danger":     "removeAuthor",
      "click a.btn-success":    "addAuthor",
      "click a.contact-author": "openContactAuthorModal"
    },
    toggleAddRemove: function(e) {
      e.preventDefault();
      var $e = $(e.target);
      if (e.target.nodeName === 'I') $e = $e.parent();
      var $other = $e.siblings();
      $e.attr('disabled', 'disabled');
      $other.removeAttr('disabled');
    },
    addAuthor: function(e) {
      this.toggleAddRemove(e);
      var authorId = this.model.get('id');
      var model = new Robin.Models.Contact({
        id: 'author_' + authorId,
        author_id: authorId, origin: 'blog',
        first_name: this.model.get('first_name'),
        last_name: this.model.get('last_name'),
        email: this.model.get('email')
      });
      this.pitchContactsCollection.add(model);
    },
    removeAuthor: function(e) {
      this.toggleAddRemove(e);
      this.pitchContactsCollection.remove('author_' + this.model.get('id'));
    },
    templateHelpers: function(){
      return {
        author: this.model,
        wordMapper: this.wordMapper
      }
    },
    initialize: function(options){
      this.releaseModel = options.releaseModel;
      this.pitchContactsCollection = options.pitchContactsCollection
    },
    openModal: function(e){
      e.preventDefault();
      
      var relatedStoriesCollection = new Robin.Collections.RelatedStories({
        author_id: this.model.get('id'),
        releaseModel: this.releaseModel
      });
      var layout = new ReleasesBlast.AuthorInspectLayout();
      Robin.modal.show(layout);
      
      var authorStatItemView = new ReleasesBlast.AuthorStatsView({
        model: this.model
      });
      layout.statsRegion.show(authorStatItemView);
      layout.relatedStoriesRegion.show(relatedStoriesCollection);
    },
    openContactAuthorModal: function(e){
      e.preventDefault();
      
      var contactAuthorFormView = new ReleasesBlast.ContactAuthorFormView({
        model: this.model,
        releaseModel: this.releaseModel
      });
      
      Robin.modal.show(contactAuthorFormView);
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
