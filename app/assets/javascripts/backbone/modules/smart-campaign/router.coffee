Robin.module 'SmartCampaign', (SmartCampaign, App, Backbone, Marionette, $, _) ->

  SmartCampaign.Router = Backbone.Marionette.AppRouter.extend
    appRoutes:
      "smart_campaign": "showPage",
      "smart_campaign/new": "showNewCampaign",
