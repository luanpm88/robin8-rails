Robin.Models.NewsRoom = Backbone.Model.extend({
  urlRoot: '/news_rooms',
  preview: function(status, options) {
    var model = this,
    url = model.url() + '/preview',
    options = {
      url: url,
      type: 'GET'
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
      var news_room = _.clone( this.attributes );
      return { news_room: news_room };
  }
});