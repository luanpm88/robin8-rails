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
    "readabilityScoreTitle":        'Too s',//polyglot.t("releases.modal.basic_tab.characteristics_view.too_short"),
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
      return polyglot.t("releases.modal.basic_tab.characteristics_view.too_short");
    }
  
    var iari = this.getReadabilityScore();
    if (iari <= 5) {
      return polyglot.t("releases.modal.basic_tab.characteristics_view.bad");
    } else if (iari <= 10) {
      return polyglot.t("releases.modal.basic_tab.characteristics_view.ok");
    } else if (iari <= 15) {
      return polyglot.t("releases.modal.basic_tab.characteristics_view.good");
    } else {
      return polyglot.t("releases.modal.basic_tab.characteristics_view.excellent");
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
