Robin.module 'DashboardKol', (DashboardKol, App, Backbone, Marionette, $, _) ->

  DashboardKol.Router = Backbone.Marionette.AppRouter.extend
    appRoutes:
      "": "showCampaigns"
      "dashboard/profile": "showProfile",
      "dashboard/score": "showScore",
      "dashboard/campaigns": "showCampaigns",
