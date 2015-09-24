Robin.module 'CampaignsList.Show', (Show, App, Backbone, Marionette, $, _) ->

  Show.Controller =
    showPage: () ->
      page = new Show.CampaignsListPage()
      Robin.layouts.main.content.show page

      campaigns = new Robin.Collections.Campaigns()
      campaigns_view = new Show.CampaignsList
        collection: campaigns
      campaigns.fetch
        success: (c, r, o) ->
          page.showChildView 'campaigns', campaigns_view
