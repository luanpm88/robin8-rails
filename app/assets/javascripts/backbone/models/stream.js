Robin.Models.Stream = Backbone.Model.extend({
  urlRoot: '/streams/',

  defaults: {
    "name": 'Untitled Stream',
  },

  stories: function() {
    if(!this.get('id')) return;
    return new Robin.Collections.Stories([], {streamId: this.get('id')});
  },

  toJSON: function() {
    var stream = _.clone( this.attributes );
    return { stream: stream };
  }
});