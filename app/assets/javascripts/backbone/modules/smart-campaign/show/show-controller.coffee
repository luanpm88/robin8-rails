Robin.module 'SmartCampaign.Show', (Show, App, Backbone, Marionette, $, _) ->

  Show.Controller = Marionette.Controller.extend
    showPage: () ->
      page = new Show.SmartCampaignPage()
      Robin.layouts.main.content.show page

      campaigns = new Robin.Collections.Campaigns()

      loading_view = new Robin.Components.Loading.LoadingView()
      page.showChildView 'campaigns', loading_view

      campaigns_view = new Show.Campaigns
        collection: campaigns
      campaigns.fetch
        success: (c, r, o) ->
          page.showChildView 'campaigns', campaigns_view
        error: (e)->
          console.log e


    showNewCampaign: (tab) ->
      s = if tab? then tab else 'start'
      page = new Show.NewCampaign
        state: s
      Robin.layouts.main.content.show page

    statsCampaign: (id) ->
      campaign = new Robin.Models.Campaign { id: id }
      campaign.fetch
        success: (m, r, o) ->
          page = new Show.StatsCampaign
            model: m
          Robin.layouts.main.content.show page

    showCampaign: (id) ->
      campaign = new Robin.Models.Campaign { id: id }
      campaign.fetch
        success: (m, r, o) ->
          page = new Show.CampaignDetails
            model: m
          Robin.layouts.main.content.show page

          campaign_accepted = new Show.CampaignAccepted
            model: m
          page.showChildView 'campaignAcceptedRegion', campaign_accepted

          campaign_negotiating = new Show.CampaignNegotiating
            model: m
          page.showChildView 'campaignNegotiatingRegion', campaign_negotiating

          campaign_invited = new Show.CampaignInvitedList
            model: m
          page.showChildView 'campaignInvitedRegion', campaign_invited

          data = m.toJSON()

          interested = {}
          users_id = _.map(data.interested_campaigns, (campaigns) -> campaigns.kol_id)
          if data.interested_campaigns.length == 0
            campaign_interested = new Show.CampaignInterested
              model: m
              interested: interested
            page.showChildView 'campaignInterestedRegion', campaign_interested

          $.get "/kols/get_categories_labels/", {users_id: users_id}, (data) =>
            if data
              interested = data
            campaign_interested = new Show.CampaignInterested
              model: m
              interested: interested
            page.showChildView 'campaignInterestedRegion', campaign_interested

            campaign_declined = new Show.CampaignDeclined
              model: m
              interested: interested
            page.showChildView 'campaignDeclinedRegion', campaign_declined

            campaign_history = new Show.CampaignHistory
              model: m
              interested: interested
            page.showChildView 'campaignHistoryRegion', campaign_history



    showEditCampaign: (id) ->
      campaign = new Robin.Models.Campaign { id: id }
      campaign.fetch
        success: (m, r, o) ->
          page = new Show.NewCampaign
            state: 'target'
            model: m
          Robin.layouts.main.content.show page

    showAddKol: () ->
      kols = new Robin.Collections.Releases()
      kols.fetch
        success: (c, r, o) ->
          page = new Show.NewCampaign
            kols: c.toJSON()
          Robin.layouts.main.content.show page
