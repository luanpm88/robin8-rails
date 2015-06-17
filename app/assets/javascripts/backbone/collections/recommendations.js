Robin.Collections.Recommendations = Backbone.Collection.extend({
  model: Robin.Models.Recommendation,
  url: '/recommendations/index.json'
});
