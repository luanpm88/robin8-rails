Robin.Models.Stream = Backbone.Model.extend({
  urlRoot: '/streams/',

  toJSON: function() {
    var stream = _.clone( this.attributes );
    return { stream: stream };
  }
});