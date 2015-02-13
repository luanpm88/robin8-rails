Robin.Models.Post = Backbone.Model.extend({
  urlRoot: '/posts/',
  paramRoot: 'post',

  defaults: {
    "text": "",
    "scheduled_date": "",
    "social_networks": {}
  },
  toJSON: function() {
    var post = _.clone( this.attributes );
    return { post: post };
  }
});