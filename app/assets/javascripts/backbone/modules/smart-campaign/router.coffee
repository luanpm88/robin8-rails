Robin.module 'SmartCampaign', (SmartCampaign, App, Backbone, Marionette, $, _) ->

  SmartCampaign.Router = Backbone.Marionette.AppRouter.extend
    appRoutes:
      "smart_campaign": "showPage",
      "smart_campaign/new": "showNewCampaign",
      "smart_campaign/new_:tab": "showNewCampaign",
      "smart_campaign/edit/:id": "showEditCampaign",
      "smart_campaign/add_kol": "showAddKol",
      # "smart_campaign/details/:id": "showCampaign"
      "smart_campaign/stats/:id": "statsCampaign"

    initialize: ->
      @bind 'all', @_trackPageview

    _trackPageview: ->
      url = Backbone.history.getFragment()
      _hmt.push(['_trackPageview', url]);
