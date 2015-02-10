Robin.Views.Layouts.Main = Backbone.Marionette.LayoutView.extend({
  template: 'layouts/templates/main',

  regions: {
    sidebar: "#sidebar-wrapper",
    saySomething: '#say-something',
    content: '#page-content'
  },

  events: {
    'click': 'hideSaySomething',
    'click #nav-profile': 'showProfile',
  },

  hideSaySomething: function(e) {
    console.log('click body from layouts');
    // Robin.vent.trigger("saySomething:hide");
  },

  showProfile: function() {
    console.log("trololo");
    if (Robin.Profile._isInitialized){
      Robin.Profile.Show.Controller.showProfilePage();
    } else {
      Robin.module('Profile').start();
    }
  },
});