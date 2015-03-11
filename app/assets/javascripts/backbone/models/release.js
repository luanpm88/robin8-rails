Robin.Models.Release = Backbone.Model.extend({
  urlRoot: '/releases',

  defaults: {
    views: '5.2k',
    likes: 223,
    coverages: 3
  },

  toJSON: function() {
    var release = _.clone( this.attributes );
    release.permalink = this.makePermalink();
    
    return { release: release };
  },
  makePermalink: function(){
    return "http://robin8/releasePermalink"
  }
});
