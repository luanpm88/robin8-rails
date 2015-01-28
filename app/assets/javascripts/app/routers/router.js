Robin.Routers.Main = Backbone.Router.extend({

  routes: {
    "": "index",
    "signin": "signin",
  },

  initialize: function() {
    console.log('routes init');
  },

  index: function() {
    console.log('index page');
  },

  signin: function() {
    var signInView = new Robin.Views.signInView();
    $('#container').html(signInView.render().el)
  },
});
