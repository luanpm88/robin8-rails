Robin.Models.Post = Backbone.Model.extend({
  urlRoot: '/posts/',

  toJSON: function() {
    var post = _.clone( this.attributes );
    return { post: post };
  }
});