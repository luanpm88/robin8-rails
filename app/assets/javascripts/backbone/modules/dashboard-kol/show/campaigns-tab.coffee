Robin.module 'DashboardKol.Show', (Show, App, Backbone, Marionette, $, _)->

  Show.CampaignsTab = Backbone.Marionette.LayoutView.extend
    template: 'modules/dashboard-kol/show/templates/campaigns-tab'

    regions:
      campaigns: "#campaigns-list"

    events:
      "click #back_to_score_btn": "score"

    onRender: () ->
      campaignsAccepted = new Robin.Collections.Campaigns()
      campaignsDeclined = new Robin.Collections.Campaigns()
      campaignsAcceptedTab = new App.Campaigns.Show.CampaignsTab
        collection: campaignsAccepted
      campaignsAccepted.accepted
        success: ()->
          campaignsPage.showChildView 'accepted', campaignsAcceptedTab
        error: (e)->
          console.log e
      campaignsDeclinedTab = new App.Campaigns.Show.CampaignsTab
        collection: campaignsDeclined
        declined: true
      campaignsDeclined.declined
        success: ()->
          campaignsPage.showChildView 'declined', campaignsDeclinedTab
        error: (e)->
          console.log e

      campaignsPage = new App.Campaigns.Show.CampaignsLayout
      @showChildView 'campaigns', campaignsPage

    score: () ->
