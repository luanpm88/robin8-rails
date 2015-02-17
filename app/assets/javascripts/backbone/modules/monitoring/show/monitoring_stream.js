Robin.module('Monitoring.Show', function(Show, App, Backbone, Marionette, $, _){

  Show.MonitoringStreamView = Backbone.Marionette.CompositeView.extend({
    template: 'modules/monitoring/show/templates/monitoring_stream',

    events: {
      'click .delete-stream': 'closeStream',
      'click .settings-button': 'settings',
      'click #close-settings': 'closeSettings',
      'click #done': 'done',
    },

    initialize: function() {
      this.model = new Robin.Models.Stream();
      // this.modelBinder = new Backbone.ModelBinder();
    },

    onRender: function() {
      // this.modelBinder.bind(this.model, this.el);
    },

    closeStream: function() {
      this.destroy();
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

      // test hardcode
      this.model.set('topics', [{"id": "Barack_Obama", "name":"Obama"}]);
      this.model.set('blogs', [
        {"id": 2107, "blog_name": "Journal Review"},
        {"id": 217,  "blog_name": "Newsday "}
      ]);
      this.model.set('sort_column', 'published_at');

      console.log(this.model);

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
