Robin.module 'DashboardKol.Show', (Show, App, Backbone, Marionette, $, _) ->

  Show.Controller = Marionette.Controller.extend
    showDashboardPage: ()->
      @dashboardPageView = new Show.DashboardKOLPage
      Robin.layouts.main.content.show @dashboardPageView

    showProfile: -> @dashboardPageView.profile()
    showScore: -> @dashboardPageView.score()
    showCampaigns: -> @dashboardPageView.campaigns()
    showDefaultDashboard: -> @dashboardPageView.defaultDashboard()
