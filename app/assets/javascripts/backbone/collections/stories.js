Robin.Collections.Stories = Backbone.Collection.extend({
  model: Robin.Models.Story,
  url: function() {
    if(!this.streamId) return;
    return '/streams/' + this.streamId + '/stories';
  },

  initialize: function(models, options) {
    _.bindAll(this, 'executePolling', 'onFetch');
  },

  startPolling: function () {
    if(this.isPollingOn) return;
    this.isPollingOn = true;
    this.pollingInterval = 1;
    this.executePolling();
  },

  stopPolling: function () {
    this.isPollingOn = false;
  },

  executePolling: function () {
    if(this.url()) {
      this.fetch({success: this.onFetch});
    } else {
      this.onFetch();
    }
  },

  onFetch: function () {
    if (!this.isPollingOn) return;
    setTimeout(this.executePolling, moment.duration(this.pollingInterval, 'minutes').asMilliseconds());
  }
});