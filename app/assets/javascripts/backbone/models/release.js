Robin.Models.Release = Backbone.Model.extend({
  urlRoot: '/releases',

  defaults: {
    statistics: {
      characters: 0,
      words: 0,
      sentences: 0,
      paragraphs: 0,
      nouns: 0,
      adjectives: 0,
      adverbs: 0,
      score: 0,
      score_title: 'Too short'
    },
    views: '5.2k',
    likes: 223,
    coverages: 3
  },

  toJSON: function() {
    var release = _.clone( this.attributes );
    return { release: release };
  }
});
