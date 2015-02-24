Robin.Models.Story = Backbone.Model.extend({
  toJSON: function() {
    var attrs = this.attributes;
    var story = _.extend(attrs, {
      likes: _.values(attrs.shares_count).reduce(function(prev, cur) { return prev + cur; }, 0),
      timeago: $.timeago(attrs.published_at),
      image: _.first(attrs.images)
    });
    return { story: story };
  }
});
