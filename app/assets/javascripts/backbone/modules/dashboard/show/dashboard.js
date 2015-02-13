Robin.module('Dashboard.Show', function(Show, App, Backbone, Marionette, $, _){
  Show.DashboardPage = Backbone.Marionette.LayoutView.extend({
    template: 'modules/dashboard/show/templates/dashboard',

  });
});