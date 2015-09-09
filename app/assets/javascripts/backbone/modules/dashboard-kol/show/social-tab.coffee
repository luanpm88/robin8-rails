Robin.module 'DashboardKol.Show', (Show, App, Backbone, Marionette, $, _)->

  Show.SocialTab = Backbone.Marionette.LayoutView.extend
    template: 'modules/dashboard-kol/show/templates/social-tab'
