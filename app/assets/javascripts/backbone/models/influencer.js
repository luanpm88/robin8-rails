Robin.Models.Influencer = Backbone.Model.extend({
  toJSON: function() {
    var influencer = _.clone( this.attributes );
    influencer.ampScore = this.ampScore();
    influencer.reachScore = this.reachScore();
    influencer.relScore = this.relScore();
    return { influencer: influencer };
  },
  ampScore: function(){
    return Math.round(this.get('ampScore'));
  },
  reachScore: function(){
    return Math.round(this.get('reachScore'));
  },
  relScore: function(){
    return Math.round(this.get('relScore'));
  }
});
