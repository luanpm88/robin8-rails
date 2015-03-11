Robin.Models.Author = Backbone.Model.extend({
  toJSON: function() {
    var author = _.clone( this.attributes );
    author.avatar_url = this.getAvatarUrl();
    
    return { author: author };
  },
  getAvatarUrl: function(){
    if (this.get('avatar_url') == null)
      return AppAssets.path('user_avatar.png');
    else
      return this.get('avatar_url');
  }
});
