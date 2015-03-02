Robin.Collections.RelatedStories = Backbone.Collection.extend({
  model: Robin.Models.Story,
  url: '/robin8_api/related_stories',
  
  initialize: function(options) {
    this.releaseModel = options.releaseModel;
    this.author_id = options.author_id;
  },
  parse: function(response) {
    return response.stories;
  },
  fetchStories: function(options){
    this.fetch({
      url: this.url,
      data: {
        id: this.author_id,
        title: this.releaseModel.get("title"), 
        body: this.releaseModel.get("text"),
        per_page: 3
      },
      method: "POST",
      success: options.success
    });
  }
});
