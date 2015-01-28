window.Robin = {
  Models: {},
  Collections: {},
  Views: {},
  Routers: {},
  initialize: function() {
    console.log('initialize backbone app');
    new Robin.Routers.Main();
    Backbone.history.start();
  }
};
$(document).ready(function() {
  Robin.initialize();
});

$(document).on('page:load', function() {
  Backbone.history.stop();
  Robin.initialize();
});
