Robin.Models.Follower = Backbone.Model.extend({
  urlRoot: '/followers',

  add: function(email, options) {
    var model = this,
    url = model.url() + '/add/?email=' + email,
    options = {
      url: url,
      type: 'POST'
    };
    var success = options.success;
    options.success = function(resp) {
      if (!model.set(model.parse(resp, options), options)) return false;
      if (success) success(model, resp, options);
      model.trigger('sync', model, resp, options);
    };

    return this.sync('read', this, options);
  },

  toJSON: function() {
    var follower = _.clone( this.attributes );
    return { follower: follower };
  }
});