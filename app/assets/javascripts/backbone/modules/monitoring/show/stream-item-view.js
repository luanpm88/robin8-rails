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
      'keydown #topics': 'loadTopics',
    },

    initialize: function() {
      this.modelBinder = new Backbone.ModelBinder();
    },

    loadTopics: function(e) {
      var model = this.model;
      $(this.el).find('#topics-select').select2({
        multiple: true,
        tags: true,
        ajax: {
          url: '/autocompletes/topics',
          dataType: 'json',
          data: function(term, page) { return { term: term } },
          results: function(data, page) { return { results: data } }
        },
        initSelection : function (element, callback) {
          console.log('initselection');
        },
        minimumInputLength: 1,
      }).on("select2-selecting", function(e) {
        var array = model.get('topics') == undefined ? [] : model.get('topics');
        var newValue = {
          id: e.val,
          text: e.object.text
        };
        array.push(newValue);
        model.set('topics', array);
      });
    },

    loadSources: function(e) {
      var model = this.model;
      $(this.el).find('#sources-select').select2({
        multiple: true,
        tags: true,
        ajax: {
          url: '/autocompletes/blogs',
          dataType: 'json',
          data: function(term, page) { return { term: term } },
          results: function(data, page) { return { results: data } }
        },
        initSelection : function (element, callback) {
          console.log('initselection');
        },
        minimumInputLength: 1,
      }).on("select2-selecting", function(e) {
        var array = model.get('blogs') == undefined ? [] : model.get('blogs');
        var newValue = {
          id: e.val,
          text: e.object.text
        };
        array.push(newValue);
        model.set('blogs', array);
      });
    },

    onRender: function() {
      this.loadTopics();
      this.loadSources();
      this.modelBinder.bind(this.model, this.el);

      if(this.model.attributes.id)
        this.$el.find('.stream-settings').addClass('closed');
    },

    closeStream: function() {
      var r = this.model;
      swal({
        title: "Delete Post?",
        text: "You will not be able to recover this post.",
        type: "error",
        showCancelButton: true,
        confirmButtonClass: 'btn-danger',
        confirmButtonText: 'Delete'
      },
      function(isConfirm) {
        if (isConfirm) {
          console.log(r);
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
