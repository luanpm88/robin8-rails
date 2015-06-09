Robin.Collections.Stories = Backbone.Collection.extend({
  model: Robin.Models.Story,

  url: function() {
    if(!this.streamId) return;
    return '/streams/' + this.streamId + '/stories.json';
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
    this.nextPage = 2;
    this.isLastPage = false;
    _.bindAll(this, 'executePolling', 'onFetch');
    this.on('add', this.onAdded);
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
    this.initialFetchAt = this.initialFetchAt || new Date();
    
    if ( Robin.currentStreamIndex + 1 < Robin.loadingStreams.length) {
      Robin.currentStreamIndex = Robin.currentStreamIndex + 1;
      var id = Robin.loadingStreams[Robin.currentStreamIndex]
      Robin.cachedStories[id].executePolling();
    } else {
      Robin.currentStreamIndex = 0;
      var id = Robin.loadingStreams[Robin.currentStreamIndex]
      setTimeout(Robin.cachedStories[id].executePolling, 120000); //in miliseconds
    }
  },

  onAdded: function(story, collection) {
    if(new Date(story.get('published_at')) > this.initialFetchAt) {
      story.set('isNew', true);
    }
  },

  fetchPreviousPage: function() {
    if(this.isLastPage || this.previousPageBeingFetched) return;

    var self = this;
    this.previousPageBeingFetched = true;

    this.fetch({data: {page: this.nextPage}, remove: false,
      success: function(collection, response, options) {
        if (response.stories.length > 0){
          self.nextPage += 1;
        } else {
          self.isLastPage = true;
        }
        
        self.previousPageBeingFetched = false;
      },
      error: function(collection, response, options) {
        collection.previousPageBeingFetched = false;
      }
    });
  }
});
