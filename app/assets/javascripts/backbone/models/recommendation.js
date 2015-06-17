Robin.Models.Recommendation = Backbone.Model.extend({
  toJSON: function() {
    var attrs = this.attributes;
    var recommendation = _.extend(attrs, { 
      timeago: ($.timeago(attrs.published_at)).replace('about',''), 
      image: _.first(attrs.images)
     });
    return { recommendation: recommendation };
  }
});

