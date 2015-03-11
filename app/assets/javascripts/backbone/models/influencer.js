Robin.Models.Influencer = Backbone.Model.extend({
  toJSON: function() {
    var influencer = _.clone( this.attributes );
    influencer.ampScore = this.ampScore();
    influencer.reachScore = this.reachScore();
    influencer.relScore = this.relScore();
    influencer.fullName = this.getFullname();
    
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
  },
  getFullname: function(){
    var firstName = this.get('firstName');
    var lastName = this.get('lastName');
    
    if (firstName && lastName)
      return (firstName + ' ' + lastName);
    else if (firstName)
      return firstName;
    else if (lastName)
      return lastName;
    else
      return "N/A"
  }
});
