Robin.module('Campaigns.Show', (Show, App, Backbone, Marionette, $, _)->

  Show.CampaignsPage = Backbone.Marionette.LayoutView.extend(
    template: 'modules/campaigns/show/templates/campaigns'
  )
)
