Robin.Models.Author = Backbone.Model.extend({
  toJSON: function() {
    var author = _.clone( this.attributes );
    return { author: author };
  }
});
