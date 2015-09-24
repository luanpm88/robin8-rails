Robin.module 'DashboardKol.Show', (Show, App, Backbone, Marionette, $, _) ->

  Show.Controller =
    showDashboardPage: ()->
      dashboardPageView = new Show.DashboardKOLPage
      Robin.layouts.main.content.show dashboardPageView

