Robin.Models.NewsRoom = Backbone.Model.extend({
  urlRoot: '/news_rooms',
  // paramRoot: 'news_room'
  toJSON: function() {
      var news_room = _.clone( this.attributes );
      return { news_room: news_room };
  }
});