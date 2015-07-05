Robin.module 'SmartCampaign.Show', (Show, App, Backbone, Marionette, $, _)->

  Show.SmartCampaignPage = Backbone.Marionette.LayoutView.extend
    template: 'modules/smart-campaign/show/templates/smart-campaign'
