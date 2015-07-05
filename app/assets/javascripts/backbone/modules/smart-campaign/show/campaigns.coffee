Robin.module 'SmartCampaign.Show', (Show, App, Backbone, Marionette, $, _)->

  Show.Campaigns = Backbone.Marionette.ItemView.extend
    template: 'modules/smart-campaign/show/templates/campaigns'

    events:
      "click #new_campaign": "newCampaign"

    newCampaign: () ->
      alert 'on the way'
