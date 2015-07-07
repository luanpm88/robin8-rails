Robin.module 'SmartCampaign.Show', (Show, App, Backbone, Marionette, $, _) ->

  Show.Controller = Marionette.Controller.extend
    showPage: () ->
      page = new Show.SmartCampaignPage()
      Robin.layouts.main.content.show page

      campaigns = new Robin.Collections.Campaigns()
      campaigns_view = new Show.Campaigns
        collection: campaigns
      campaigns.fetch
        success: (c, r, o) ->
          page.showChildView 'campaigns', campaigns_view

      kols = new Robin.Collections.PrivateKols()
      kols_view = new Show.Kols
        collection: kols
      kols.fetch
        success: (c, r, o) ->
          page.showChildView 'kols', kols_view

    showNewCampaign: () ->
      releases = new Robin.Collections.Releases()
      releases.fetch
        success: (c, r, o) ->
          page = new Show.NewCampaign
            releases: c.toJSON()
          Robin.layouts.main.content.show page

