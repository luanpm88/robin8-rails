Robin.Collections.Authors = Backbone.Collection.extend({
  model: Robin.Models.Author,
  url: '/robin8_api/authors',
  
  fetchAuthors: function(data, options){
    this.fetch({
      url: this.url,
      data: _.defaults(this.parseParams(data),{
        per_page: 100,
        included_email: true
      }),
      success: options.success
    });
  },
  parseParams: function(params){
    var new_params = {};
    
    _(params).each(function(val, key){
      switch(key){
        case 'contactName':
          if (val && val.length > 0)
            new_params['author_name'] = val;
          break;
        case 'keywords':
          if (val && val.length > 0)
            new_params['keywords[]'] = val;
          break;
        case 'location':
          if (val && val.length > 0)
            new_params['location'] = val;
          break;
        case 'outlet':
          if (val && val.length > 0)
            new_params['blog_name'] = val
          break;
      }
    });
    
    return new_params;
  }
});
