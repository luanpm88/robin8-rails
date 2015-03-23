Robin.Models.Analytics = Backbone.Model.extend({
  url: '/news_rooms/analytics',
  toJSON: function() {
    var analytics = _.clone( this.attributes );
    return { analytics: analytics };
  }
});