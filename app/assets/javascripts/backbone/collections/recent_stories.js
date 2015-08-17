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
    var params = {
      "author_ids[]": this.author_id,
      per_page: 3
    };

    if (Robin.currentUser.get('locale') == 'zh'){
      params.type = "weibo";
      params.published_at = "[* TO *]";
    }

    this.fetch({
      url: this.url,
      data: params,
      success: options.success
    });
  },
  fetchWeiboStories: function(options){
    var params = {
      "author_ids[]": this.author_id,
      type: 'weibo',
      published_at: '[* TO *]',
      per_page: 3
    };

    this.fetch({
      url: this.url,
      data: params,
      success: options.success
    });
  }
});
