Robin.module('Monitoring.Show', function(Show, App, Backbone, Marionette, $, _){

  Show.StreamCompositeView = Backbone.Marionette.CompositeView.extend({
    template: 'modules/monitoring/show/templates/monitoring_stream',
    tagName: "li",
    className: "stream",
    childViewContainer: ".stories",

    events: {
      'click .delete-stream': 'closeStream',
      'click .settings-button': 'settings',
      'click .rss-button': 'toggleRssDialog',
      'click #close-settings': 'closeSettings',
      'click #done': 'done',
      'click span.editable': 'editTitle',
      'click .editable-submit': 'updateTitle',
      'click .js-show-new-stories': 'showNewStories',
      'click .rss-input': 'selectLink',
    },

    collectionEvents: {
      add: 'onAdded'
    },

    modelEvents: {
      change: 'setShowUpdatesButtonVisibility',
      'change:sort_column': 'refreshTimeRangeVisibility'
    },

    selectLink: function (e) {
      $(e.target).select();
    },

    templateHelpers: function () {
      return {
        topicsForRss: function(){
          if (this.stream && this.stream.topics) {
            var arr = this.stream.topics;
            var str = _.pluck(arr.slice(0,3), 'text').join(',');
            return arr.length > 3 ? (str+'...') : str
          }
        },
        blogsForRss: function(){
          if (this.stream && this.stream.blogs) {
            var arr = this.stream.blogs;
            var str = _.pluck(arr.slice(0,3), 'text').join(',');
            return arr.length > 3 ? (str+'...') : str
          }
        }
      };
    },

    initialize: function() {
      this.modelBinder = new Backbone.ModelBinder();

      var streamId = this.model.get('id');

      if (streamId && !Robin.cachedStories[streamId]) {
        Robin.cachedStories[streamId] = new Robin.Collections.Stories();
        Robin.cachedStories[streamId].streamId = streamId;
        Robin.cachedStories[streamId].sortByPopularity = this.model.get('sort_column') == 'shares_count';

      }

      this.collection = Robin.cachedStories[streamId] || new Robin.Collections.Stories();
      this.collection.startPolling();

      this.refreshNewStoriesCount();

      this.childView = Show.StoryItemView;
    },

    onRender: function() {
      this.$el.attr("data-pos",this.model.id)
      $.fn.editable.defaults.mode = 'inline';
      this.$el.find('span.editable').editable({inputclass: 'edit-title'});
      this.loadInfo('topics');
      this.loadInfo('blogs');
      this.modelBinder.bind(this.model, this.el);

      if (!this.model.get('id')) {
        this.$el.find('.settings-dialog').removeClass('closed');
      }
      this.$el.find('[data-toggle=tooltip]').tooltip({trigger:'hover'});

      this.$el.find('.stream-body').on('scroll', this.checkScroll(this));

      this.refreshTimeRangeVisibility();
    },

    onAdded: function(story, collection) {
      this.refreshNewStoriesCount();
      this.setShowUpdatesButtonVisibility();
    },

    editTitle: function() {
      this.$el.find('.edit-title').attr('name', 'name')
      this.modelBinder.bind(this.model, this.el);
    },

    updateTitle: function() {
      this.modelBinder.copyViewValuesToModel();
      this.model.save(this.model.attributes, {
        success: function(data){
          console.log(data);
        },
        error: function(data){
          console.warn('error', data);
        }
      });
    },

    loadInfo: function(val) {
      var currentModel = this.model;
      var currentValue = '';

      $(this.el).find('#' + val + '-select').select2({
        multiple: true,
        tags: true,
        ajax: {
          url: '/autocompletes/' + val,
          dataType: 'json',
          data: function(term, page) { 
            currentValue = term;
            return { term: term } 
          },
          results: function(data, page) { 
            if (data.length > 3) {
              data.splice(0, 1);
            } 
            if (val == 'topics') {
              newValue = {
                id: currentValue,
                text: 'Add ' + currentValue + ' as keyword',
                type: 'keyword'
              };
              data.unshift(newValue);
            }
            return { results: data }; 
          }
        },
        initSelection : function (element, callback) {
          if (val == 'topics') {
            callback(currentModel.attributes[val].concat(currentModel.attributes['keywords']));
          } else {
            callback(currentModel.attributes[val]);
          }
        },
        minimumInputLength: 1,
      }).on("select2-selecting", function(e) {
        if (e.object.type == 'keyword' && val == 'topics') {
          var getKeyword = currentModel.get('keywords') == undefined ? [] : currentModel.get('keywords');;
          var newValue = {
            id: e.val,
            text: e.val,
            type: 'keyword'
          };
          getKeyword.push(newValue);
          currentModel.set('keywords', getKeyword);
          e.object.text = e.object.id
        } else {
          var getTopics = currentModel.get(val) == undefined ? [] : currentModel.get(val);;
          var newValue = {
            id: e.val,
            text: e.object.text
          };
          getTopics.push(newValue);
          currentModel.set(val, getTopics);
        }
      }).on("select2-removed", function(e) {
        if (e.choice.type == 'keyword' && val == 'topics') {
          var getKeywords = currentModel.get('keywords') == undefined ? [] : currentModel.get('keywords');
          var updatedKeywords = _.reject(getKeywords, function(k){ return k.id == e.val; });

          currentModel.set('keywords', updatedKeywords);
        } else {
          var getTopics = currentModel.get(val) == undefined ? [] : currentModel.get(val);;
          var updatedTopics = _.reject(getTopics, function(k){ return k.id == e.val; });

          currentModel.set(val, updatedTopics);
        }
      });
      $(this.el).find('#' + val + '-select').select2('val', currentModel.attributes[val]);
    },

    closeStream: function() {
      var r = this.model;
      if(!r.get('id')) return r.destroy({ dataType: "text"});
      swal({
        title: "Delete Stream?",
        text: "You will not be able to recover this stream.",
        type: "error",
        showCancelButton: true,
        confirmButtonClass: 'btn-danger',
        confirmButtonText: 'Delete'
      },
      function(isConfirm) {
        if (isConfirm) {
          r.destroy({ dataType: "text"});
        }
      });
    },

    toggleRssDialog: function(){
      $(this.el).find('.rss-dialog').toggleClass('closed');
    },

    settings: function() {
      $(this.el).find('.settings-dialog').toggleClass('closed');
    },

    closeSettings: function(e) {
      e.preventDefault();
      $(this.el).find('.settings-dialog').addClass('closed');
      if(!this.model.get('id')) this.closeStream();
    },

    done: function(e) {
      e.preventDefault();

      var curView = this;

      this.model.save(this.model.attributes, {
        success: function(userSession, response) {
          curView.collection.streamId = response.id;
          curView.collection.fetch({reset: true});

          Robin.cachedStories[response.id] = curView.collection;
          Robin.cachedStories[response.id].sortByPopularity = curView.model.get('sort_column') == 'shares_count';

          $(curView.el).attr("data-pos",response.id);
          $(curView.el).find('.settings-dialog').addClass('closed');
          $.growl({message: "Your stream was saved!"
          },{
            type: 'success'
          });
          curView.render();
        },
        error: function(userSession, response) {
          $.growl({title: '<strong>Error:</strong> ',
            message: 'Something went wrong.'
          },{
            type: 'danger'
          });
        }
      });

      $(this.el).find('.settings-dialog').addClass('closed');
    },

    showNewStories: function() {
      this.collection.where({isNew: true}).forEach(function(story) {
        story.set('isNew', false);
      });
      this.model.set('newStoriesCount', 0);
      this.collection.refreshInitialFetchAt();
      this.setShowUpdatesButtonVisibility();
    },

    refreshNewStoriesCount: function() {
      this.model.set('newStoriesCount', this.collection.where({isNew: true}).length);
    },

    checkScroll: function(view) {
      return function () {
        var triggerPoint = 100;
        if( !view.isLoading && this.scrollTop + this.clientHeight + triggerPoint > this.scrollHeight ) {
          view.collection.fetchPreviousPage();
        }
      }
    },

    setShowUpdatesButtonVisibility: function() {
      if(this.model.get('newStoriesCount') > 0) {
        this.$el.find('.js-show-new-stories').removeClass('hidden');
      } else {
        this.$el.find('.js-show-new-stories').addClass('hidden');
      }
    },

    refreshTimeRangeVisibility: function(){
      var val = this.model.get('sort_column');
      if(val == "shares_count") {
        this.$el.find('.stream-settings .time-range').show();
        this.$el.find('.stream-settings').addClass('expand');
      } else if(val == "published_at") {
        this.$el.find('.stream-settings .time-range').hide();
        this.$el.find('.stream-settings').removeClass('expand');
      }
    }
  });

});
