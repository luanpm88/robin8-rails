Robin.module 'SmartCampaign.Show', (Show, App, Backbone, Marionette, $, _)->

  Show.NewCampaign = Backbone.Marionette.ItemView.extend
    template: 'modules/smart-campaign/show/templates/new-campaign'
