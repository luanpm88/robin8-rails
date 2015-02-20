Robin.Collections.Stories = Backbone.Collection.extend({
  model: Robin.Models.Story,
  url: function() {
    return '/streams/' + this.streamId + '/stories';
  },

  initialize: function(models, options) {
    this.streamId = options.streamId;
    _.bindAll(this, 'executePolling', 'onFetch');
  },

  startPolling: function () {
    this.isPollingOn = true;
    this.pollingInterval = 1;
    this.executePolling();
  },

  stopPolling: function () {
    this.isPollingOn = false;
  },

  executePolling: function () {
    this.fetch({success : this.onFetch});
  },

  onFetch: function () {
    if (!this.isPollingOn) return;
    setTimeout(this.executePolling, moment.duration(this.pollingInterval, 'minutes').asMilliseconds());
  }
});