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
    var params = {
      id: this.author_id,
      title: this.releaseModel.get("title"), 
      body: this.releaseModel.get("plain_text"),
      "iptc_categories[]": this.releaseModel.get("iptc_categories"),
      per_page: 3
    };
    
    if (Robin.currentUser.get('locale') == 'zh'){
      params.type = "weibo";
      params.published_at = "[* TO *]";
      delete params["iptc_categories[]"];
    }
    
    this.fetch({
      url: this.url,
      data: params,
      method: "POST",
      success: options.success
    });
  }
});
