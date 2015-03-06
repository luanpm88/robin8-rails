Robin.Models.ReleaseCharacteristics = Backbone.Model.extend({
  defaults: {
    "numberOfWords":                0,
    "numberOfNouns":                0,
    "numberOfAdverbs":              0,
    "readabilityScore":             0,
    "numberOfSentences":            0,
    "numberOfCharacters":           0,
    "numberOfParagraphs":           0,
    "numberOfAdjectives":           0,
    "readabilityScoreTitle":        "Too Short",
    "numberOfNonSpaceCharacters":   0
  },
  titleToProgressBarLevel: {
    'Ok' : 'prograss-bar-warning',
    'Bad': 'progress-bar-danger',
    'Good': 'progress-bar-info',
    'Excellent': 'progress-bar-success',
    'Too short': 'progress-bar-success'
  },
  getReadabilityScoreTitle: function() {
    if(this.get("numberOfWords") <= 3) {
      return 'Too short';
    }
  
    var iari = this.getReadabilityScore();
    if (iari <= 5) {
      return 'Bad';
    } else if (iari <= 10) {
      return 'Ok';
    } else if (iari <= 15) {
      return 'Good';
    } else {
      return 'Excellent';
    }
  },
  getReadabilityScore: function() {
    if(this.get("numberOfWords") <= 3) {
      return 0;
    }
 
    var ari = Math.round(
      (4.71 * (this.get("numberOfNonSpaceCharacters") / this.get("numberOfWords"))) +
      (0.5 * (this.get("numberOfWords")  / this.get("numberOfSentences"))) - 21.43
    ) || 0;
    var iari = 20 - ari;
    if (iari < 0) iari = 0;
    if (iari > 20) iari = 20;

    return iari;
  }
});
