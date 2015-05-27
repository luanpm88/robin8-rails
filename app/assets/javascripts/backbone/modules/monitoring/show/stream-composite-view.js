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
      'click .make-keyword': 'makeKeyword',
    },

    collectionEvents: {
      add: 'onAdded',
      'reset': 'afterFetch',
      'sync': 'afterFetch',
      'request': 'showLoading',
    },

    modelEvents: {
      change: 'setShowUpdatesButtonVisibility',
      'change:sort_column': 'refreshTimeRangeVisibility'
    },

    showLoading: function (e) {
      this.$el.find('.stream-loading').removeClass('hidden');
      this.$el.find('.empty-stream').addClass('hidden');
    },

    afterFetch: function (e) {
      this.filterCollection();
      this.$el.find('.stream-loading').addClass('hidden');
      this.$el.find('.stream-body').removeClass('opacity-02');
      if (this.collection.length != 0) {
        this.$el.find('.empty-stream').addClass('hidden');
      } else {
        this.$el.find('.empty-stream').removeClass('hidden');
      };
    },

    makeKeyword: function (e) {
      var view = this;
      var topics = this.model.get('topics');
      var getKeywords = this.model.get('keywords') == undefined ? [] : this.model.get('keywords');;
      view.model.set('topics', [])

      $.each(topics, function( index, topic ) {
        var new_keyword = topic.text.replace(/\W/gi, ' ').split(' ');
        $.each(new_keyword, function( index, key ) {
          if (key.length > 0) {
            var newValue = {
              id: key,
              text: key,
              type: 'keyword'
            };
            getKeywords.push(newValue);
          }
        });

      });
      view.model.set('keywords', getKeywords);
      view.model.save( view.model.attributes, {
        success: function(userSession, response){
          view.collection.streamId = response.id;
          view.collection.fetch({reset: true});
          Robin.loadingStreams.push(view.collection.streamId);

          Robin.cachedStories[response.id] = view.collection;
          Robin.cachedStories[response.id].sortByPopularity = view.model.get('sort_column') == 'shares_count';

          $.growl({message: "Your topics was saved as keywords!"
          },{
            type: 'success'
          });
          Robin.cachedStories[view.model.get('id')].alreadyRendered = false;
          view.render();
        },
        error: function(data){
          console.warn('error', data);
        }
      });
      view.$el.find('.stream-loading').removeClass('hidden');
      view.$el.find('.empty-stream').addClass('hidden');
    },

    filterCollection: function () {
      var initArray = this.collection.models;
      var deleteList = [];
      var ViewObj = this;

      initArray.forEach(function(model) {
        var title = model.attributes.title;
        deleteResult = $.grep(initArray, function(e){
          return ((e.attributes.title == model.attributes.title) && (e.attributes.id != model.attributes.id))
        });
        initArray = $.grep(initArray, function(e){
          return !((e.attributes.title == model.attributes.title) && (e.attributes.id != model.attributes.id))
        });
        if (deleteResult.length > 0) {
          var id = deleteResult[0].attributes.id ;
          var itemToDelete = ViewObj.collection.get(id);
          ViewObj.collection.remove(itemToDelete);
        }
      });
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
        Robin.loadingStreams.push(streamId);

        Robin.cachedStories[streamId] = new Robin.Collections.Stories();
        Robin.cachedStories[streamId].streamId = streamId;
        Robin.cachedStories[streamId].alreadyRendered = false;
        Robin.cachedStories[streamId].sortByPopularity = this.model.get('sort_column') == 'shares_count';

      }

      this.collection = Robin.cachedStories[streamId] || new Robin.Collections.Stories();
      
      if (Robin.loadingStreams.length == 1) {
        Robin.currentStreamIndex = 0;
        this.collection.executePolling();
      }

      this.refreshNewStoriesCount();

      this.childView = Show.StoryItemView;
    },

    onRender: function() {
      var curView = this;
      Robin.user.fetch({
        success: function() {
          if (Robin.user.get('can_create_stream') != true) {
            curView.$el.find("#add-stream").addClass('disabled-unavailable');
          } else {
            curView.$el.find("#add-stream").removeClass('disabled-unavailable');
          }
        }
      });
      this.$el.attr("data-pos",this.model.id)
      $.fn.editable.defaults.mode = 'inline';
      this.$el.find('span.editable').editable({inputclass: 'edit-title'});
      this.loadInfo('topics');
      this.loadInfo('blogs');
      this.modelBinder.bind(this.model, this.el);

      if (Robin.cachedStories[this.model.get('id')] != undefined) {
        if (Robin.cachedStories[this.model.get('id')].length > 0){
          this.$el.find('.stream-loading').addClass('hidden');
        } 
        
        if (Robin.cachedStories[this.model.get('id')].alreadyRendered && Robin.cachedStories[this.model.get('id')].length == 0) {
          this.$el.find('.stream-loading').addClass('hidden');
          this.$el.find('.empty-stream').removeClass('hidden');
        }
        Robin.cachedStories[this.model.get('id')].alreadyRendered = true;
      }


      if (this.needOpacity) {
        this.$el.find('.stream-loading').removeClass('hidden');
        this.$el.find('.stream-body').addClass('opacity-02');
      }

      if (!this.model.get('id')) {
        this.$el.find('.stream-loading').addClass('hidden');
        this.$el.find('.settings-dialog').removeClass('closed');
      } 

      this.$el.find('[data-toggle=tooltip]').tooltip({trigger:'hover'});
      this.$el.find('.stream-body').on('scroll', this.checkScroll(this));

      this.refreshTimeRangeVisibility();
      this.$el.find("input.select2-input").css('width', '150%')
    },

    onAdded: function(story, collection) {
      this.filterCollection();
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
      var currentView = this;

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
        if ( _.where(currentModel.attributes.topics, e.object).length > 0){
          e.preventDefault()
          $.growl("You have already select this item!", {
            type: "success",
          });
        } else {
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
      var curView = this;
      var r = this.model;
      var modelId = r.id;
      if(!r.get('id')) return r.destroy({
        dataType: "text",
        success: function() {
          Robin.user.fetch({
            success: function() {
              if (Robin.user.get('can_create_stream') != true) {
                $("#add-stream").addClass('disabled-unavailable');
              } else {
                $("#add-stream").removeClass('disabled-unavailable');
              }
            }
          });
        }
      });
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
          r.destroy({ 
            dataType: "text",
            success: function() {
              var index = Robin.loadingStreams.indexOf(modelId);
              if (index > -1) {
                Robin.loadingStreams.splice(index, 1);
              } 

              Robin.user.fetch({
                success: function() {
                  if (Robin.user.get('can_create_stream') != true) {
                    $("#add-stream").addClass('disabled-unavailable');
                  } else {
                    $("#add-stream").removeClass('disabled-unavailable');
                  }
                }
              });
            }
          });
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
          Robin.user.fetch({
            success: function() {
              if (Robin.user.get('can_create_stream') != true) {
                $("#add-stream").addClass('disabled-unavailable');
              } else {
                $("#add-stream").removeClass('disabled-unavailable');
              }
            }
          });
          curView.collection.streamId = response.id;
          curView.collection.fetch({reset: true});
          Robin.loadingStreams.push(curView.collection.streamId);

          Robin.cachedStories[response.id] = curView.collection;
          Robin.cachedStories[response.id].sortByPopularity = curView.model.get('sort_column') == 'shares_count';

          $(curView.el).attr("data-pos",response.id);
          $(curView.el).find('.settings-dialog').addClass('closed');
          $.growl({message: "Your stream was saved!"
          },{
            type: 'success'
          });
          Robin.cachedStories[curView.model.get('id')].alreadyRendered = false;
          curView.render();
        },
        error: function(userSession, response) {
          var result = $.parseJSON(response.responseText);
          _(response.responseJSON).each(function(errors,field) {
            _(errors).each(function(error, i) {
              formatted_field = s(field).capitalize().value().replace('_', ' ');
              $.growl({title: '<strong>' + formatted_field + ':</strong> ',
                message: error
              }, {
                type: "danger",
              });
            });
          });
        }
      });

      curView.$el.find('.stream-loading').removeClass('hidden');
      curView.$el.find('.stream-body').addClass('opacity-02');
      curView.$el.find('.empty-stream').addClass('hidden');
      curView.needOpacity = true;
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
