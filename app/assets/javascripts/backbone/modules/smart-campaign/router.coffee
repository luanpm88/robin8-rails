Robin.module 'SmartCampaign', (SmartCampaign, App, Backbone, Marionette, $, _) ->

  SmartCampaign.Router = Backbone.Marionette.AppRouter.extend
    appRoutes:
      "smart_campaign": "showPage",
      "smart_campaign/new": "showNewCampaign",
      "smart_campaign/add_kol": "showAddKol",
      "smart_campaign/details/:id": "showCampaign",

