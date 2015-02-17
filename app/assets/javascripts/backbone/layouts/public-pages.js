Robin.Views.Layouts.PublicPages = Backbone.Marionette.LayoutView.extend({
  template: 'layouts/templates/public-pages',

  // regions: {
  //   sidebar: "#sidebar-wrapper",
  //   saySomething: '#say-something',
  //   content: '#page-content'
  // },

  events: {
    'click nav, div#main-wrapper': 'hideSaySomething',
    'click #nav-profile': 'showProfile',
  },

  hideSaySomething: function(e) {
    console.log('clicked');
    // Robin.vent.trigger("saySomething:hide");
  },

  showProfile: function() {
    Robin.stopOtherModules();
    Robin.module('Profile').start();
  },
});