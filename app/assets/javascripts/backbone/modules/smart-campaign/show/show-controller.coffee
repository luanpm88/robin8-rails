Robin.module 'SmartCampaign.Show', (Show, App, Backbone, Marionette, $, _) ->

  Show.Controller =
    showPage: ()->
      Robin.layouts.main.content.show(new Show.SmartCampaignPage())
