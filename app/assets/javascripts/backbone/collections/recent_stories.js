Robin.Collections.RecentStories = Backbone.Collection.extend({
  model: Robin.Models.Story,
  url: '/robin8_api/stories',
  
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
        "author_ids[]": this.author_id,
        per_page: 3
      },
      success: options.success
    });
  }
});
