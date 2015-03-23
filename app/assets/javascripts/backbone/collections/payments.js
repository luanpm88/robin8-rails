Robin.Collections.Payments = Backbone.Collection.extend({
  model: Robin.Models.Payment,
  url: '/payments/'
});