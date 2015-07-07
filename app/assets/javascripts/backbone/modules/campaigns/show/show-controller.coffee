Robin.module 'Campaigns.Show', (Show, App, Backbone, Marionette, $, _) ->

  Show.Controller =
    showPage: ()->
      campaignsAccepted = new Robin.Collections.Campaigns()
      campaignsDeclined = new Robin.Collections.Campaigns()
      campaignsAcceptedTab = new Show.CampaignsTab
        collection: campaignsAccepted
      campaignsAccepted.accepted
        success: ()->
          campaignsPage.showChildView 'accepted', campaignsAcceptedTab
        error: (e)->
          console.log e
      campaignsDeclinedTab = new Show.CampaignsTab
        collection: campaignsDeclined
        declined: true
      campaignsDeclined.declined
        success: ()->
          campaignsPage.showChildView 'declined', campaignsDeclinedTab
        error: (e)->
          console.log e

      campaignsPage = new Show.CampaignsLayout
      Robin.layouts.main.content.show campaignsPage
