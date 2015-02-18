Robin.module('Monitoring.Show', function(Show, App, Backbone, Marionette, $, _){

  Show.StreamItemView = Backbone.Marionette.CompositeView.extend({
    template: 'modules/monitoring/show/templates/monitoring_stream',
    tagName: "li",
    className: "stream",

    events: {
      'click .delete-stream': 'closeStream',
      'click .settings-button': 'settings',
      'click #close-settings': 'closeSettings',
      'click #done': 'done',
      'click span.editable': 'editTitle',
      'click .editable-submit': 'updateTitle',
    },

    modelEvents: {
      "change": "fetchStories"
    },

    initialize: function() {
      this.modelBinder = new Backbone.ModelBinder();
    },

    onRender: function() {
      $.fn.editable.defaults.mode = 'inline';
      this.$el.find('span.editable').editable({inputclass: 'edit-title'});
      this.loadInfo('topics');
      this.loadInfo('blogs');
      this.modelBinder.bind(this.model, this.el);

      if (this.model.attributes.id) {
        this.$el.find('.stream-settings').addClass('closed');
      }
      this.fetchStories();
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

    fetchStories: function() {
      var stream = this.model.attributes;
      if(!stream.id) return;
      this.$el.find('.stream-settings').addClass('closed');

      var storiesCollectionView = new Show.StoriesCollectionView({
        collection: new Robin.Collections.Stories([], {streamId: stream.id}),
        childView: Show.StoryItemView
      });

      this.$el.find('.stream-body').html(storiesCollectionView.render().el);
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

      this.model.set('sort_column', 'published_at');

      this.model.save(this.model.attributes, {
        success: function(userSession, response) {
          $(this.el).find('.slider').addClass('closed');
          $.growl({message: "You've created a stream"
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
    }
  });

});
