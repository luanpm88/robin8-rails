Robin.Models.EmailInfo = Backbone.Model.extend({
  // url: '/news_rooms/analytics',
  toJSON: function() {
    var emailInfo = _.clone( this.attributes );
    return { emailInfo: emailInfo };
  }
});