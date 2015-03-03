Robin.Collections.Authors = Backbone.Collection.extend({
  model: Robin.Models.Author,
  url: '/robin8_api/authors',
  
  fetchAuthors: function(options){
    this.fetch({
      url: this.url,
      data: {
        per_page: 5
      },
      success: options.success
    });
  }
});
