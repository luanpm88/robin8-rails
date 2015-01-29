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
    if(Robin.currentUser) {
      Robin.main.show(Robin.layouts.main);
    }
    else {
      document.location.hash = '#signin';
    }
  },

  signin: function() {
    Robin.layouts.unauthenticated.getRegion('signUpForm').show(new Robin.Views.signInView());
  },

  signup: function() {
    Robin.layouts.unauthenticated.getRegion('signUpForm').show(new Robin.Views.signUpView());
  },
});
