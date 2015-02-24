Robin.module('Monitoring.Show', function(Show, App, Backbone, Marionette, $, _){

  Show.StreamCompositeView = Backbone.Marionette.CompositeView.extend({
    template: 'modules/monitoring/show/templates/monitoring_stream',
    tagName: "li",
    className: "stream",
    childViewContainer: ".stories",

    events: {
      'click .delete-stream': 'closeStream',
      'click .settings-button': 'settings',
      'click #close-settings': 'closeSettings',
      'click #done': 'done',
      'click span.editable': 'editTitle',
      'click .editable-submit': 'updateTitle',
      'click .js-show-new-stories': 'showNewStories'
    },

    collectionEvents: {
      add: 'onAdded'
    },

    modelEvents: {
      change: 'render'
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
        this.$el.find('.stream-settings').removeClass('closed');
      }
      this.$el.find('[data-toggle=tooltip]').tooltip({trigger:'hover'});
    },

    onAdded: function(story, collection) {
      this.refreshNewStoriesCount();
      this.render();
    },

    editTitle: function() {
      this.$el.find('.edit-title').attr('name', 'name')
      this.modelBinder.bind(this.model, this.el);
    },

    updateTitle: function() {
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

      $(this.el).find('#' + val + '-select').select2({
        multiple: true,
        tags: true,
        ajax: {
          url: '/autocompletes/' + val,
          dataType: 'json',
          data: function(term, page) { return { term: term } },
          results: function(data, page) { return { results: data } }
        },
        initSelection : function (element, callback) {
          callback(currentModel.attributes[val]);
        },
        minimumInputLength: 1,
      }).on("select2-selecting", function(e) {
        var getTopics = currentModel.get(val) == undefined ? [] : currentModel.get(val);;
        var newValue = {
          id: e.val,
          text: e.object.text
        };
        getTopics.push(newValue);

        currentModel.set(val, getTopics);
      }).on("select2-removed", function(e) {
        var getTopics = currentModel.get(val) == undefined ? [] : currentModel.get(val);;
        var updatedTopics = _.reject(getTopics, function(k){ return k.id == e.val; });

        currentModel.set(val, updatedTopics);
      });
      $(this.el).find('#' + val + '-select').select2('val', currentModel.attributes[val]);
    },

    closeStream: function() {
      var r = this.model;
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

    settings: function() {
      $(this.el).find('.slider').toggleClass('closed');
    },

    closeSettings: function(e) {
      e.preventDefault();
      $(this.el).find('.slider').addClass('closed');
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
          $(curView.el).find('.slider').addClass('closed');
          $.growl({message: "Your stream was saved!"
          },{
            type: 'success'
          });
        },
        error: function(userSession, response) {
          $.growl({title: '<strong>Error:</strong> ',
            message: 'Something went wrong.'
          },{
            type: 'danger'
          });
        }
      });

      $(this.el).find('.slider').addClass('closed');
    },

    showNewStories: function() {
      this.collection.where({isNew: true}).forEach(function(story) {
        story.set('isNew', false);
      });
      this.model.set('newStoriesCount', 0);
      this.collection.refreshInitialFetchAt();
      this.render();
    },

    refreshNewStoriesCount: function() {
      this.model.set('newStoriesCount', this.collection.where({isNew: true}).length);
    }
  });

});
