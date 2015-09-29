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
      kols_view = new Show.KolsView
        collection: kols
      kols.fetch
        success: (c, r, o) ->
          kolsPage.showChildView 'influencersRegion', kols_view

      kols_list = new Robin.Collections.KolsLists()
      kols_list_view = new Show.KolsList
        collection: kols_list
      kols_list.fetch
        success: (c, r, o) ->
          kolsPage.showChildView 'influencersListRegion', kols_list_view

      kolsPage = new Show.Kols
      page.showChildView 'kols', kolsPage

    showNewCampaign: (tab) ->
      s = if tab? then tab else 'start'
      page = new Show.NewCampaign
        state: s
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

          campaign_declined = new Show.CampaignDeclined
            model: m
          page.showChildView 'campaignDeclinedRegion', campaign_declined

          campaign_negotiating = new Show.CampaignNegotiating
            model: m
          page.showChildView 'campaignNegotiatingRegion', campaign_negotiating

          campaign_invited = new Show.CampaignInvitedList
            model: m
          page.showChildView 'campaignInvitedRegion', campaign_invited

          data = m.toJSON()
          categories_id = _.map(data.kol_categories, (categories) -> categories.iptc_category_id)
          category_labels = {}
          if data.kol_categories.length == 0
            campaign_interested = new Show.CampaignInterested
              model: m
              category_labels: category_labels
            page.showChildView 'campaignInterestedRegion', campaign_interested

          $.get "/kols/get_categories_labels/", {categories_id: categories_id}, (data) =>
            if data
              category_labels = data
            campaign_interested = new Show.CampaignInterested
              model: m
              category_labels: category_labels
            page.showChildView 'campaignInterestedRegion', campaign_interested

          campaign_history = new Show.CampaignHistory
            model: m
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
