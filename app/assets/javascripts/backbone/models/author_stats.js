Robin.Models.AuthorStats = Backbone.Model.extend({
  toJSON: function() {
    var authorStats = _.clone( this.attributes );
    return { authorStats: authorStats };
  }
});
