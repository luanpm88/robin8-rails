Robin.module 'DashboardKol.Show', (Show, App, Backbone, Marionette, $, _)->

  Show.DashboardKOLPage = Backbone.Marionette.CompositeView.extend
    template: 'modules/dashboard-kol/show/templates/dashboard'
