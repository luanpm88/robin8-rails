Robin.module 'Campaigns.Show', (Show, App, Backbone, Marionette, $, _)->

  Show.NegotiateCampDialog = Backbone.Marionette.LayoutView.extend
    template: 'modules/campaigns/show/templates/negotiate-campaign'

    ui:
      negotiateText: '#negotiate-text'
      errorBlock: 'p#report-error'

    events:
      "click #negotiate-save": "negotiateSave"

    serializeData: () ->
      campaign_name: @options.campaign_name

    negotiateSave: () ->
      text = @ui.negotiateText.val()
      if text == ''
        @ui.negotiateText.parent().addClass("has-error")
        @ui.errorBlock.removeClass("hidden")
        return
      else if @ui.negotiateText.parent().hasClass("has-error")
        @ui.negotiateText.parent().removeClass("has-error")
        @ui.errorBlock.addClass("hidden")
      if text != ''
        data = {}
        data["text"] = text
        data["id"] = @options.article_id
        self = this
        $.post "/campaign/negotiate_campaign/negotiate/", data, (data) =>
          if data.comment_type == "comment"
            $.growl({message: polyglot.t('dashboard_kol.campaigns_tab.negotiate_success')
            },{
              type: 'success'
            })
            $('#modal').modal('hide')
            $('body').removeClass('modal-open')
            $('.modal-backdrop').remove()
            $('.fade').remove()
            negotiating = new Robin.Collections.Campaigns()
            campaignsNegotiatingTab = new App.Campaigns.Show.CampaignsTab
              collection: negotiating
              declined: false
              accepted: false
              history: false
              negotiating: true
            negotiating.negotiating
              success: ()->
                self.options.layout.negotiating.show campaignsNegotiatingTab
              error: (e)->
                console.log e

            campaignsAccepted = new Robin.Collections.Campaigns
            campaignsAcceptedTab = new Show.CampaignsTab
              declined: false
              accepted: true
              history: false
              negotiating: false
              collection: campaignsAccepted
            campaignsAccepted.accepted
              success: ()->
                self.options.layout.accepted.show campaignsAcceptedTab
              error: (e)->
                console.log e

            campaignsDeclined = new Robin.Collections.Campaigns
            campaignsDeclinedTab = new Show.CampaignsTab
              collection: campaignsDeclined
              accepted: false
              history: false
              negotiating: false
              declined: true
            campaignsDeclined.declined
              success: ()->
                self.options.layout.declined.show campaignsDeclinedTab
              error: (e)->
                console.log e

            invites = new Robin.Collections.CampaignInvitations
            campaignsInvitationTab = new Show.CampaignsInvitations
              collection: invites
            invites.fetch
              success: ()->
                self.options.layout.invitation.show campaignsInvitationTab
              error: (e)->
                console.log e
          else
            $.growl({message: polyglot.t('dashboard_kol.campaigns_tab.negotiate_error')
            },{
              type: 'danger'
            })
