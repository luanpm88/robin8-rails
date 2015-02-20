Robin.Models.Story = Backbone.Model.extend({
  toJSON: function() {
    var attrs = this.attributes;
    var story = _.extend(attrs, {
      likes: _.values(attrs.shares_count).reduce(function(prev, cur) { return prev + cur; }, 0),
      timeago: moment().diff(attrs.published_at, 'hours'),
      image: _.first(attrs.images)
    });
    return { story: story };
  }
});
