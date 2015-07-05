Robin.module 'SmartCampaign.Show', (Show, App, Backbone, Marionette, $, _)->

  Show.Kols = Backbone.Marionette.ItemView.extend
    template: 'modules/smart-campaign/show/templates/kols'
