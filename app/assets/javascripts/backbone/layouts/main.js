Robin.Views.Layouts.Main = Backbone.Marionette.LayoutView.extend({
  template: JST['layouts/main'],

  regions: {
    sidebar: "#sidebar-wrapper",
    content: '#page-content'
  }
});