Robin.module 'Campaigns.Show', (Show, App, Backbone, Marionette, $, _)->

  Show.CampaignsLayout = Backbone.Marionette.LayoutView.extend
    template: 'modules/campaigns/show/templates/layout'
    regions:
      accepted: "#accepted"
      invitation: "#invitation"
      negotiating: "#negotiating"
      declined: "#declined"
      history: "#history"
      all: "#all"
      latest: "#latest"

  Show.CampaignsTab = Backbone.Marionette.ItemView.extend
    template: 'modules/campaigns/show/templates/campaigns'
    templateHelpers:
      formatDate: (d) ->
        date = new Date d
        date.toLocaleFormat '%d-%b-%Y'
      timestamp: (d) ->
        date = new Date d
        date.getTime()
      code: (campaign) ->
        if campaign.tracking_code? and campaign.tracking_code != 'Waiting'
          polyglot.t('kol_campaign.approved')
        else if campaign.tracking_code? and campaign.tracking_code == 'Waiting'
          polyglot.t('smart_campaign.pending_approval')
        else
          polyglot.t('kol_campaign.in_progress')
      code_status: (campaign) ->
        if campaign.invite_status == 'A' and campaign.tracking_code != 'Negotiating'
          polyglot.t('kol_campaign.approved')
        else if campaign.invite_status == 'D' and campaign.tracking_code != 'Negotiating'
          polyglot.t('dashboard_kol.campaigns_tab.rejected')
        else
          polyglot.t('dashboard_kol.campaigns_tab.expired')
      budget: (campaign) ->
        if campaign.non_cash == false or campaign.non_cash == null
          "$ " + campaign.budget
        else
          campaign.short_description

    events:
      "click .campaign": "show_editor"
      "click .invitation-accept": "accept"
      "click .invitation-decline": "decline"

    accept: (event) ->
      event.preventDefault()
      console.log 'here'
      console.log event
      @perform_action($(event.currentTarget))

    decline: (event) ->
      event.preventDefault()
      @perform_action($(event.currentTarget), "decline")

    perform_action: (button, action="accept") ->
      self = this
      button_container = button.parent().parent()
      id = button.data("campaignId")
      item = self.collection.get(id)
      data = {}
      data["status"] = if action == "accept" then "A" else "D"
      data["campaign_id"] = id
      $.post "/campaign_invite/change_invite_status", data, (data) =>
        if data.status == data["status"]
          invites = new Robin.Collections.CampaignInvitations()
          campaignsInvitationTab = new Show.CampaignsInvitations
            collection: invites
          invites.fetch
            success: ()->
              self._parentLayoutView().invitation.show campaignsInvitationTab
            error: (e)->
              console.log e

          end = moment(new Date(item.attributes.created_at).toLocaleFormat '%d-%b-%Y')
          start = moment(Date.today().toLocaleFormat('%d-%b-%Y'))
          diff = start.diff(end, "days")
          if diff > 0
            latest = new Robin.Collections.Campaigns
            campaignsLatestTab = new Show.CampaignsSuggestedTab
              collection: latest
            latest.latest
              success: ()->
                self._parentLayoutView().latest.show campaignsLatestTab
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
              self._parentLayoutView().accepted.show campaignsAcceptedTab
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
              self._parentLayoutView().declined.show campaignsDeclinedTab
            error: (e)->
              console.log e

          negotiating = new Robin.Collections.Campaigns()
          campaignsNegotiatingTab = new App.Campaigns.Show.CampaignsTab
            collection: negotiating
            declined: false
            accepted: false
            history: false
            negotiating: true
          negotiating.negotiating
            success: ()->
              self._parentLayoutView().negotiating.show campaignsNegotiatingTab
            error: (e)->
              console.log e

    show_editor: (event) ->
      id = $(event.currentTarget).data("id")
      model = this.collection.get(id)
      article = new Robin.Models.Article
        campaign_model: model
      no_tabs = false
      if this.options.history
        no_tabs = true
      self = this
      article.fetch
        success: ()=>
          articleDialog.render()
          article.fetch_comments(()->
            commentsList = new Show.ArticleComments
              collection: article.get("article_comments")
            articleDialog.showChildView 'comments', commentsList
          )
          article.fetch_wechat_perf(()->
            wechat_performance = if article.get("wechat_performance")? then article.get("wechat_performance") else []
            canUpload = true
            if wechat_performance.length > 0
              end = moment(new Date(wechat_performance.models[0].attributes.period))
              start = moment(Date.today())
              diff = start.diff(end, "days")
              if diff < 7
                canUpload = false
            if self.options.history
              canUpload = false
            weChetPerf = new Show.ArticleWeChat
              collection: article.get("wechat_performance")
              model: article
              disabled: false
              canUpload: canUpload
            articleDialog.showChildView 'weChat', weChetPerf
          )
        error: (e)->
          console.log e
      no_comments = true
      if @options.accepted or @options.negotiating
        no_comments = false
      articleDialog = new Show.ArticleDialog
        model: article
        title: model.get("name")
        no_tabs: no_tabs
        no_comments: no_comments
        declined: @options.declined
        accepted: @options.accepted
        history: @options.history
        negotiating: @options.negotiating
      Robin.modal.show articleDialog

    serializeData: () ->
      items: @collection.toJSON()
      declined: if @options.declined then @options.declined else false
      accepted: if @options.accepted then @options.accepted else false
      history: if @options.history then @options.history else false
      negotiating: if @options.negotiating then @options.negotiating else false

    onRender: () ->
      @$el.find('table').DataTable
        info: false
        searching: false
        lengthChange: false
        pageLength: 25


  Show.ArticleComments = Backbone.Marionette.ItemView.extend
    template: 'modules/campaigns/show/templates/article-comments'
    templateHelpers:
      formatDate: (d) ->
        date = new Date d
        date.toLocaleFormat '%d-%b-%Y %I:%M %r'
      timestamp: (d) ->
        date = new Date d
        date.getTime()

  Show.ArticleWeChat = Backbone.Marionette.ItemView.extend
    template: 'modules/campaigns/show/templates/article-wechat'

    templateHelpers:
      getClass: (status) ->
        if status == "Approved"
          return "approved_status"
        if status == "Rejected"
          return "rejected_status"
        else
          return ""

    serializeData: () ->
      items: @collection.toJSON()
      disabled: @options.disabled
      canUpload: @options.canUpload

    onRender: () ->
      @$el.find('table').DataTable
        info: false
        searching: false
        lengthChange: false
        pageLength: 10
        autoWidth: false
        columnDefs: [sortable: false, targets: ["no-sort"]]
        order: [[ 0, "desc" ]]
      if !@options.canUpload and document.getElementById("report_region")?
        document.getElementById("report_region").style.display = "none"

  Show.CampaignsInvitations = Backbone.Marionette.ItemView.extend
    template: 'modules/campaigns/show/templates/campaigns-invitations'

    events:
      "click .invitation-accept": "accept"
      "click .invitation-decline": "decline"
      "click #negotiate": "negotiate_campaign"
      "click .campaign": "show_editor"

    templateHelpers:
      formatDate: (d) ->
        date = new Date d
        date.toLocaleFormat '%d-%b-%Y'
      timestamp: (d) ->
        date = new Date d
        date.getTime()
      budget: (campaign) ->
        if campaign.non_cash == false or campaign.non_cash == null
          "$ " + campaign.budget
        else
          campaign.short_description

    serializeData: () ->
      items: @collection.toJSON()

    onRender: () ->
      @$el.find('table').DataTable
        info: false
        searching: false
        lengthChange: false
        pageLength: 25

    negotiate_campaign: (event) ->
      id = $(event.currentTarget).data("inviteId")
      model = this.collection.get(id)
      negotiateCampaignDialog = new Show.NegotiateCampDialog
        model: model
        campaign_name: model.attributes.campaign.name
        article_id: model.attributes.campaign.id
        layout: this._parentLayoutView()
      Robin.modal.show negotiateCampaignDialog

    show_editor: (event) ->
      id = $(event.currentTarget).data("id")
      model = this.collection.get(id)
      article = new Robin.Models.Article
        campaign_model: model
      no_tabs = false
      if this.options.history
        no_tabs = true
      self = this
      article.fetch
        success: ()=>
          articleDialog.render()
          article.fetch_comments(()->
            commentsList = new Show.ArticleComments
              collection: article.get("article_comments")
            articleDialog.showChildView 'comments', commentsList
          )
          article.fetch_wechat_perf(()->
            wechat_performance = if article.get("wechat_performance")? then article.get("wechat_performance") else []
            canUpload = true
            if wechat_performance.length > 0
              end = moment(new Date(wechat_performance.models[0].attributes.period))
              start = moment(Date.today())
              diff = start.diff(end, "days")
              if diff < 7
                canUpload = false
            if self.options.history
              canUpload = false
            weChetPerf = new Show.ArticleWeChat
              collection: article.get("wechat_performance")
              model: article
              disabled: false
              canUpload: canUpload
            articleDialog.showChildView 'weChat', weChetPerf
          )
        error: (e)->
          console.log e
      no_comments = true
      if @options.accepted or @options.negotiating
        no_comments = false
      articleDialog = new Show.ArticleDialog
        model: article
        title: model.get("name")
        no_tabs: no_tabs
        no_comments: no_comments
        declined: false
        accepted: true
        history: false
        negotiating: false
      Robin.modal.show articleDialog


    accept: (event) ->
      event.preventDefault()
      @perform_action($(event.currentTarget))

    decline: (event) ->
      event.preventDefault()
      @perform_action($(event.currentTarget), "decline")

    perform_action: (button, action="accept") ->
      self = this
      button_container = button.parent().parent()
      id = button.data("inviteId")
      item = self.collection.get(id)
      action_method = if action == "accept" then item.accept() else item.decline()
      $.when(action_method).then ()->
        button_container.remove()
        self.render()
        campaignsAccepted = new Robin.Collections.Campaigns
        campaignsAcceptedTab = new Show.CampaignsTab
          declined: false
          accepted: true
          history: false
          negotiating: false
          collection: campaignsAccepted
        campaignsAccepted.accepted
          success: ()->
            self._parentLayoutView().accepted.show campaignsAcceptedTab
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
            self._parentLayoutView().declined.show campaignsDeclinedTab
          error: (e)->
            console.log e

        end = moment(new Date(item.attributes.campaign.created_at))
        start = moment(Date.today())
        diff = start.diff(end, "days")
        if diff > 0
          latest = new Robin.Collections.Campaigns
          campaignsLatestTab = new Show.CampaignsSuggestedTab
            collection: latest
          latest.latest
            success: ()->
              self._parentLayoutView().latest.show campaignsLatestTab
            error: (e)->
              console.log e

  Show.CampaignsSuggestedTab = Backbone.Marionette.ItemView.extend
    template: 'modules/campaigns/show/templates/campaigns-suggested'

    events:
      "click .camp-interested": "camp_interested"
      "click .campaign": "show_editor"

    templateHelpers:
      formatDate: (d) ->
        date = new Date d
        date.toLocaleFormat '%d-%b-%Y'
      timestamp: (d) ->
        date = new Date d
        date.getTime()
      budget: (campaign) ->
        if campaign.non_cash == false or campaign.non_cash == null
          "$ " + campaign.budget
        else
          campaign.short_description

    serializeData: () ->
      items: @collection.toJSON()
      all: @options.all

    onRender: () ->
      @$el.find('table').DataTable
        info: false
        searching: false
        lengthChange: false
        pageLength: 25

    camp_interested: (event) ->
      self = this
      id = $(event.currentTarget).data("campaignId")
      $.post "/campaign_invite/ask_for_invite/", {interested_campaign_id: id}, (data) =>
        if data
          $.growl(polyglot.t('smart_campaign.success_ask_invite'), {type: "success"})
          latest = new Robin.Collections.Campaigns()
          campaignsLatestTab = new App.Campaigns.Show.CampaignsSuggestedTab
            collection: latest
            declined: false
            accepted: false
            history: false
            negotiating: false
          latest.latest
            success: ()->
              console.log self
              self._parentLayoutView().latest.show campaignsLatestTab
            error: (e)->
              console.log e
          campaignsAll = new Robin.Collections.Campaigns()
          campaignsAllTab = new App.Campaigns.Show.CampaignsSuggestedTab
            collection: campaignsAll
            all: true
            declined: false
            accepted: false
            history: false
            negotiating: false
          campaignsAll.all
            success: ()=>
              self._parentLayoutView().all.show campaignsAllTab
            error: (e)->
              console.log e

        else
          $.growl(polyglot.t('smart_campaign.something_wrong'), {type: "danger"})


    show_editor: (event) ->
      id = $(event.currentTarget).data("id")
      campaign_model = this.collection.get(id)
      article = new Robin.Models.Article
        campaign_model: campaign_model
        id: id
        canUpload: false
      articleDialog = new Show.ArticleDialog
        model: article
        title: campaign_model.get("name")
        no_tabs: no_tabs
        no_comments: true
        declined: @options.declined
        accepted: @options.accepted
        history: @options.history
        negotiating: @options.negotiating

      no_tabs = false
      if this.options.history
        no_tabs = true
      self = this
      article.fetch
        success: ()->
          articleDialog.render()
          article.fetch_comments(()->
            commentsList = new App.Campaigns.Show.ArticleComments
              collection: article.get("article_comments")
            articleDialog.showChildView 'comments', commentsList
          )
          article.fetch_wechat_perf(()->
            wechat_performance = if article.get("wechat_performance")? then article.get("wechat_performance") else []
            weChetPerf = new Show.ArticleWeChat
              collection: wechat_performance
              disabled: true
              canUpload: false
            articleDialog.showChildView 'weChat', weChetPerf
          )
        error: (e)->
          console.log e
      Robin.modal.show articleDialog

