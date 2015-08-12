Robin.Collections.SuggestedAuthors = Backbone.Collection.extend({
  model: Robin.Models.Author,
  url: '/robin8_api/suggested_authors',
  
  initialize: function(options) {
    this.releaseModel = options.releaseModel;
  },
  fetchAuthors: function(options){
    var params = {
      title: this.releaseModel.get("title"), 
      body: this.releaseModel.get("plain_text"),
      "iptc_categories[]": this.releaseModel.get("iptc_categories"),
      per_page: 100,
      included_email: true
    };
    
    if (Robin.currentUser.get('locale') == 'zh'){
      params.type = "weibo";
      params.published_at = "[* TO *]";
      delete params["iptc_categories[]"];
    }
    
    if (!s.isBlank(this.releaseModel.get('location'))){
      params['location'] = this.releaseModel.get('location');
      params['blog_location'] = this.releaseModel.get('location');
    }
    
    if (!s.isBlank(this.releaseModel.get('author_type_id')))
      params['author_type_ids[]'] = this.releaseModel.get('author_type_id');
    
    this.fetch({
      url: this.url,
      data: params,
      method: "POST",
      success: options.success
    });
  }
});
