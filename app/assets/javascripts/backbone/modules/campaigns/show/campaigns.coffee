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
          link = "http://#{window.location.host}/articles/#{campaign.tracking_code}"
          "<a href=\"#{link}\">#{link}</a>"
        else
          polyglot.t('kol_campaign.not_approved_yet')
      code_status: (campaign) ->
        if campaign.tracking_code? and campaign.tracking_code == 'Waiting'
          "Pending approval"
        else if campaign.tracking_code? and campaign.tracking_code != 'Waiting'
          polyglot.t('kol_campaign.approved')
        else
          polyglot.t('kol_campaign.in_progress')

    events:
      "click .campaign": "show_editor"

    show_editor: (event) ->
      id = $(event.currentTarget).data("id")
      model = this.collection.get(id)
      article = new Robin.Models.Article
        campaign_model: model
      article.fetch
        success: ()->
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
              end = moment(new Date(wechat_performance.models[0].attributes.period).toLocaleFormat '%d-%b-%Y')
              start = moment(Date.today().toLocaleFormat('%d-%b-%Y'))
              diff = start.diff(end, "days")
              if diff < 7
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
      articleDialog = new Show.ArticleDialog
        model: article
        title: model.get("name")
      Robin.modal.show articleDialog

    serializeData: () ->
      items: @collection.toJSON()
      declined: @options.declined
      accepted: @options.accepted
      history: @options.history
      negotiating: @options.negotiating

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
    templateHelpers:
      formatDate: (d) ->
        date = new Date d
        date.toLocaleFormat '%d-%b-%Y'
      timestamp: (d) ->
        date = new Date d
        date.getTime()

    serializeData: () ->
      items: @collection.toJSON()

    onRender: () ->
      @$el.find('table').DataTable
        info: false
        searching: false
        lengthChange: false
        pageLength: 25

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
        if action == "accept"
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
        else
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

        campaignsAll = new Robin.Collections.Campaigns
        campaignsAllTab = new Show.CampaignsSuggestedTab
          collection: campaignsAll
          all: true
        campaignsAll.all
          success: ()->
           self._parentLayoutView().all.show campaignsAllTab
          error: (e)->
            console.log e

  Show.CampaignsSuggestedTab = Backbone.Marionette.ItemView.extend
    template: 'modules/campaigns/show/templates/campaigns-suggested'

    events:
      "click .camp-interested": "camp_interested"
      "click .camp-not-interested": "camp_not_interested"

    templateHelpers:
      formatDate: (d) ->
        date = new Date d
        date.toLocaleFormat '%d-%b-%Y'
      timestamp: (d) ->
        date = new Date d
        date.getTime()

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
      id = $(event.currentTarget).data("campaignId")

    camp_not_interested: (event) ->
      id = $(event.currentTarget).data("campaignId")
