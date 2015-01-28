Robin.Routers.Main = Backbone.Marionette.AppRouter.extend({

  routes: {
    "": "index",
    "signin": "signin",
    "signup": "signup",
  },

  initialize: function() {
    console.log('routes init');
  },

  index: function() {
    console.log('index');
  },

  signin: function() {
    var layoutView = new AppLayoutView();
    $('#container').html(layoutView.render().el)
    layoutView.getRegion('signUpForm').show(new Robin.Views.signInView());
  },

  signup: function() {
    var signUpView = new Robin.Views.signUpView();
    $('#container').html(signUpView.render().el)
  },
});
