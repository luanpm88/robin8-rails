Robin.Models.Subscription = Backbone.Model.extend({
  urlRoot: '/subscriptions/',

  toJSON: function() {
    var subscription = _.clone( this.attributes );
    return { subscription: subscription };
  }
});
