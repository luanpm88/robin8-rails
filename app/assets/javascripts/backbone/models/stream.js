Robin.Models.Stream = Backbone.Model.extend({
  urlRoot: '/streams/',

  defaults: {
    name: 'Untitled Stream',
    newStoriesCount: 0
  },

  toJSON: function() {
    var stream = _.clone( this.attributes );
    return { stream: stream };
  }
});
