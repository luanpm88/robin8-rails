Robin.module 'DashboardKol.Show', (Show, App, Backbone, Marionette, $, _)->

  Show.CampaignsTab = Backbone.Marionette.LayoutView.extend
    template: 'modules/dashboard-kol/templates/campaigns-tab'

    regions:
      campaigns: "#campaigns-list"

    events:
      "click #back_to_score_btn": "score"
      "click td.campaign" : "highlightRow"

    onRender: () ->
      # campaignsAccepted = new Robin.Collections.Campaigns()
      # campaignsAcceptedTab = new App.Campaigns.Show.CampaignsTab
      #   collection: campaignsAccepted
      #   accepted: true
      #   history: false
      #   negotiating: false
      #   declined: false
      # campaignsAccepted.accepted
      #   success: ()->
      #     campaignsPage.showChildView 'accepted', campaignsAcceptedTab
      #   error: (e)->
      #     console.log e
      #
      # campaignsDeclined = new Robin.Collections.Campaigns()
      # campaignsDeclinedTab = new App.Campaigns.Show.CampaignsTab
      #   collection: campaignsDeclined
      #   declined: true
      #   accepted: false
      #   history: false
      #   negotiating: false
      # campaignsDeclined.declined
      #   success: ()->
      #     campaignsPage.showChildView 'declined', campaignsDeclinedTab
      #   error: (e)->
      #     console.log e
      #
      # campaignsAll = new Robin.Collections.Campaigns()
      # campaignsAllTab = new App.Campaigns.Show.CampaignsSuggestedTab
      #   collection: campaignsAll
      #   all: true
      #   declined: false
      #   accepted: false
      #   history: false
      #   negotiating: false
      # campaignsAll.all
      #   success: ()->
      #     campaignsPage.showChildView 'all', campaignsAllTab
      #   error: (e)->
      #     console.log e
      #
      # invites = new Robin.Collections.CampaignInvitations()
      # campaignsInvitationTab = new App.Campaigns.Show.CampaignsInvitations
      #   collection: invites
      # invites.fetch
      #   success: ()->
      #     campaignsPage.showChildView 'invitation', campaignsInvitationTab
      #   error: (e)->
      #     console.log e
      #
      # latest = new Robin.Collections.Campaigns()
      # campaignsLatestTab = new App.Campaigns.Show.CampaignsSuggestedTab
      #   collection: latest
      #   declined: false
      #   accepted: false
      #   history: false
      #   negotiating: false
      # latest.latest
      #   success: ()->
      #     campaignsPage.showChildView 'latest', campaignsLatestTab
      #   error: (e)->
      #     console.log e
      #
      # history = new Robin.Collections.Campaigns()
      # campaignsHistoryTab = new App.Campaigns.Show.CampaignsTab
      #   collection: history
      #   declined: false
      #   accepted: false
      #   history: true
      #   negotiating: false
      # history.history
      #   success: ()->
      #     campaignsPage.showChildView 'history', campaignsHistoryTab
      #   error: (e)->
      #     console.log e
      #
      # negotiating = new Robin.Collections.Campaigns()
      # campaignsNegotiatingTab = new App.Campaigns.Show.CampaignsTab
      #   collection: negotiating
      #   declined: false
      #   accepted: false
      #   history: false
      #   negotiating: true
      # negotiating.negotiating
      #   success: ()->
      #     campaignsPage.showChildView 'negotiating', campaignsNegotiatingTab
      #   error: (e)->
      #     console.log e
      #
      # campaignsPage = new App.Campaigns.Show.CampaignsLayout
      # @showChildView 'campaigns', campaignsPage
      # $('#modal').on 'hidden.bs.modal', () ->
      #   $('#campaigns-list tr.selected').removeClass 'selected'

    score: () ->
      @options.parent.setState('score')

    highlightRow: (event) ->
      $(event.target).parent('tr').addClass('selected')
