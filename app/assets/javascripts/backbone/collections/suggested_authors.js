Robin.Collections.SuggestedAuthors = Backbone.Collection.extend({
  model: Robin.Models.Author,
  url: '/robin8_api/suggested_authors',
  
  initialize: function(options) {
    this.releaseModel = options.releaseModel;
  },
  fetchAuthors: function(options){
    this.fetch({
      url: this.url,
      data: {
        title: this.releaseModel.get("title"), 
        body: this.releaseModel.get("text"),
        per_page: 25
      },
      method: "POST",
      success: options.success
    });
  }
});
