Robin.Views.Layouts.Main = Backbone.Marionette.LayoutView.extend({
  template: 'layouts/templates/main',

  regions: {
    sidebar: "#sidebar-wrapper",
    saySomething: '#say-something',
    content: '#page-content'
  },

  events: {
    'click body': 'hideSaySomething'
  },

  hideSaySomething: function() {
    Robin.vent.trigger("saySomething:hide");
  }

});