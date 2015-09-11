Robin.module 'DashboardKol.Show', (Show, App, Backbone, Marionette, $, _)->

  Show.CampaignsTab = Backbone.Marionette.LayoutView.extend
    template: 'modules/dashboard-kol/show/templates/campaigns-tab'

    regions:
      campaigns: "#campaigns-list"

    events:
      "click #back_to_score_btn": "score"

    onRender: () ->
      campaignsAccepted = new Robin.Collections.Campaigns()
      campaignsAcceptedTab = new App.Campaigns.Show.CampaignsTab
        collection: campaignsAccepted
      campaignsAccepted.accepted
        success: ()->
          campaignsPage.showChildView 'accepted', campaignsAcceptedTab
        error: (e)->
          console.log e

      campaignsDeclined = new Robin.Collections.Campaigns()
      campaignsDeclinedTab = new App.Campaigns.Show.CampaignsTab
        collection: campaignsDeclined
        declined: true
      campaignsDeclined.declined
        success: ()->
          campaignsPage.showChildView 'declined', campaignsDeclinedTab
        error: (e)->
          console.log e

      campaignsAll = new Robin.Collections.Campaigns()
      campaignsAllTab = new App.Campaigns.Show.CampaignsSuggestedTab
        collection: campaignsAll
        all: true
      campaignsAll.all
        success: ()->
          campaignsPage.showChildView 'all', campaignsAllTab
        error: (e)->
          console.log e

      invites = new Robin.Collections.CampaignInvitations()
      campaignsInvitationTab = new App.Campaigns.Show.CampaignsInvitations
        collection: invites
      invites.fetch
        success: ()->
          campaignsPage.showChildView 'invitation', campaignsInvitationTab
        error: (e)->
          console.log e

      industry = new Robin.Collections.Campaigns()
      campaignsIndustryTab = new App.Campaigns.Show.CampaignsSuggestedTab
        collection: industry
      industry.industry
        success: ()->
          campaignsPage.showChildView 'my_industry', campaignsIndustryTab
        error: (e)->
          console.log e

      campaignsPage = new App.Campaigns.Show.CampaignsLayout
      @showChildView 'campaigns', campaignsPage

    score: () ->
      @options.parent.setState('score')
