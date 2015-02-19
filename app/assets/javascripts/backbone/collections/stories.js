Robin.Collections.Stories = Backbone.Collection.extend({
  model: Robin.Models.Story,
  url: function() {
    return '/streams/' + this.streamId + '/stories';
  },

  initialize: function(models, options) {
    this.streamId = options.streamId;
  }
});