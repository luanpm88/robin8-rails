Robin.module 'DashboardKol.Show', (Show, App, Backbone, Marionette, $, _)->

  Show.CampaignsTab = Backbone.Marionette.LayoutView.extend
    template: 'modules/dashboard-kol/show/templates/campaigns-tab'
