Robin.Collections.SuggestedAuthors = Backbone.Collection.extend({
  model: Robin.Models.Author,
  
  initialize: function(options) {
    this.max_min = null;
    this.releaseModel = options.releaseModel;
    this.getSuggestedAuthors();
  },
  calculateLevelOfInterest: function(score, author_name) {
    if (this.max_min == null)
      this.max_min = this.calculateMaxMin(author_name);
    var a = this.max_min[0]; b = this.max_min[1];
    var xMinMax = this.max_score - this.min_score;
    var deltaBA = b - a;
    var normalized_score = a + ((score - this.min_score) * deltaBA / xMinMax);
    return normalized_score.toFixed(2);
  },
  calculateMaxMin: function(author_name) {
    var min_max_arr = {
      0: [65.68, 99.56], 1: [66.23, 98.85], 2: [67.38, 97.94], 
      3: [68.15, 96.02], 4: [69.08, 95.16], 5: [70.12, 94.42],
      6: [66.74, 93.62], 7: [69.36, 92.23], 8: [70.52, 91.94],
      9: [66.03, 90.09]
    };
    var result = 0;
    if (author_name) {
        result = _.reduce(author_name.split(''), function (memo, number) {
            if (_.isNaN(parseInt(number)) === false) {
                memo += parseInt(number);
            }
            return memo;
        }, 0);
    }

    var key = result % 10;

    return min_max_arr[key];
  },
  getSuggestedAuthors: function(){
    var self = this;
      
    $.ajax({
      url: 'robin8_api/suggested_authors',
      dataType: 'json',
      method: 'POST',
      data: {
        title: self.releaseModel.attributes.title, 
        body: self.releaseModel.attributes.text,
        per_page: 50
      },
      success: function(response){
        self.max_score = response[0].score;
        self.min_score = response[response.length - 1].score;
        var suggestedAuthors = _(response).map(function(item){
          item["levelOfInterest"] = self.calculateLevelOfInterest(
            item["score"], 
            getFullname(item["first_name"], item["last_name"])
          );
          return item;
        });
        self.reset(suggestedAuthors);
      }
    });
  }
});
