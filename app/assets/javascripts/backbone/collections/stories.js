Robin.Collections.Stories = Backbone.Collection.extend({
  model: Robin.Models.Story,

  url: function() {
    if(!this.streamId) return;
    return '/streams/' + this.streamId + '/stories';
  },

  parse: function(response) {
    return response.stories;
  },

  comparator: function(story) {
    if(this.sortByPopularity) {
      return -story.get('likes');
    } else {
      return -new Date(story.get('published_at'));
    }
  },

  initialize: function(models, options) {
    _.bindAll(this, 'executePolling', 'onFetch');
    this.on('add', this.onAdded);
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
      this.fetch({success: this.onFetch, remove: false});
    } else {
      this.onFetch();
    }
  },

  refreshInitialFetchAt: function() {
    this.initialFetchAt = null;
  },

  onFetch: function () {
    if (!this.isPollingOn) return;
    this.initialFetchAt = this.initialFetchAt || new Date();
    setTimeout(this.executePolling, moment.duration(this.pollingInterval, 'minutes').asMilliseconds());
  },

  onAdded: function(story, collection) {
    if(this.initialFetchAt < new Date()) {
      story.set('isNew', true);
    }
  }
});
