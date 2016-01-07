Robin.module 'DashboardKol', (DashboardKol, App, Backbone, Marionette, $, _) ->

  DashboardKol.Router = Backbone.Marionette.AppRouter.extend
    appRoutes:
      "": "showDefaultDashboard"
      "dashboard/profile": "showProfile",
      "dashboard/score": "showScore",
      "dashboard/campaigns": "showCampaigns",
      'dashboard/default': 'showDefaultDashboard'
  
  initialize: ->
    @bind 'all', @_trackPageview

  _trackPageview: ->
    url = Backbone.history.getFragment()
    _hmt.push(['_trackPageview', "/#{url}"])