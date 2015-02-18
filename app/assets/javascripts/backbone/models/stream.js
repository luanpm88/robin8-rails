Robin.Models.Stream = Backbone.Model.extend({
  urlRoot: '/streams/',

  defaults: {
    "name": 'Untitled Stream',
  },

  toJSON: function() {
    var stream = _.clone( this.attributes );
    return { stream: stream };
  }
});