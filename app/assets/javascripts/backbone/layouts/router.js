Robin.Routers.Main = Backbone.Marionette.AppRouter.extend({

  routes: {
    "signup": 'signup',
    "forgot": "forgot"
  },

  index: function() {
    if(Robin.currentUser) {
      Robin.main.show(Robin.layouts.main);
    }
    else {
      document.location.hash = '#signin';
    }
  },

  signup: function() {
    console.log('main router signup!')
    // Robin.layouts.unauthenticated.getRegion('signUpForm').show(new Robin.Views.signUpView());
  },

  forgot: function() {
    // Robin.layouts.unauthenticated.getRegion('signUpForm').show(new Robin.Views.forgotView());
  },
});
