Robin.Views.Layouts.Main = Backbone.Marionette.LayoutView.extend({
  template: 'layouts/templates/main',

  regions: {
    sidebar: "#sidebar-wrapper",
    saySomething: '#say-something',
    content: '#page-content'
  },

  events: {
    'click': 'hideSaySomething'
  },

  hideSaySomething: function(e) {
    window.$e = e
    console.log('click body from layouts');
    // Robin.vent.trigger("saySomething:hide");
  }

});