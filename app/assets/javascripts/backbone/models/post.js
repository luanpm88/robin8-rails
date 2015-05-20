Robin.Models.Post = Backbone.Model.extend({
  urlRoot: '/posts/',
  defaults: {
    "twitter_ids":  [],
    "facebook_ids":  [],
    "linkedin_ids":  []
  },

  toJSON: function() {
    var post = _.clone( this.attributes );
    return { post: post };
  },

  updateSocial: function(data, options) {    
    var model = this,
    url = model.url() + '/update_social',
    options = {
      data: { post: { social_networks: data } },
      url: url,
      type: 'PUT'
    };
    var success = options.success;
    options.success = function(resp) {
      if (!model.set(model.parse(resp, options), options)) return false;
      if (success) success(model, resp, options);
      model.trigger('sync', model, resp, options);
    };

    return this.sync('read', this, options);
  }
});