Robin.module 'SmartCampaign.Show', (Show, App, Backbone, Marionette, $, _)->

  Show.CampaignDetails = Backbone.Marionette.LayoutView.extend
    template: 'modules/smart-campaign/show/templates/campaign_details/campaign-details'

    regions:
      campaignAcceptedRegion: '#campaign-accepted'
      campaignNegotiatingRegion: '#campaign-negotiating'
      campaignDeclinedRegion: '#campaign-declined'
      campaignInvitedRegion: '#campaign-invited'
      campaignInterestedRegion: '#campaign-interested'
      campaignHistoryRegion: '#campaign-history'

    templateHelpers:
      formatDate: (d) ->
        date = new Date d
        monthNum = parseInt(date.getMonth()) + 1
        date.toLocaleFormat '%d-' + polyglot.t('date.monthes_abbr.m' + monthNum) + '-%Y'

    serializeData: () ->
      campaign: @model.toJSON()

    events:
      "click #edit_campaign": "edit"

    edit: () ->
      start_tab_view = new Show.NewCampaign (
        model: @model
      )
      Robin.layouts.main.content.show(start_tab_view)

  Show.CampaignAccepted = Backbone.Marionette.ItemView.extend
    template: 'modules/smart-campaign/show/templates/campaign_details/campaign-accepted'

    templateHelpers:
      formatDate: (d) ->
        date = new Date d
        monthNum = parseInt(date.getMonth()) + 1
        date.toLocaleFormat '%d-' + polyglot.t('date.monthes_abbr.m' + monthNum) + '-%Y'
      timestamp: (d) ->
        date = new Date d
        date.getTime()
      public: (k) ->
        if k.is_public then polyglot.t('smart_campaign.yes') else polyglot.t('smart_campaign.no')
      status: (k) ->
        if k.status == "" then polyglot.t('smart_campaign.unknown') else polyglot.t('smart_campaign.declined')
      code: (k) ->
        if k.article? and k.article.tracking_code? and k.article.tracking_code != 'Waiting'
          link = "http://#{window.location.host}/articles/#{k.article.tracking_code}"
          "<a href=\"#{link}\">#{link}</a>"
        else
          polyglot.t('smart_campaign.not_approved_yet')
      code_status: (k) ->
        if k.article? and k.article.tracking_code? and k.article.tracking_code != 'Waiting'
          polyglot.t('smart_campaign.approved')
        else
          polyglot.t('smart_campaign.in_progress')

    events:
      "click tr.preview": "preview"

    preview: (e) ->
      id = $(e.currentTarget).data "article-id"
      article = new Robin.Models.Article
        campaign_model: @model
        id: id
        canUpload: false
      articleDialog = new App.Campaigns.Show.ArticleDialog
        model: article
        title: @model.get("name")
        disabled: true
        onApprove: (code) ->
          $("#code_#{id}").html code
          $("#code_status_#{id}").html 'Approved'
      article.fetch
        success: ()->
          articleDialog.render()
          article.fetch_comments ()->
            commentsList = new App.Campaigns.Show.ArticleComments
              collection: article.get("article_comments")
            articleDialog.showChildView 'comments', commentsList
          article.fetch_wechat_perf ()->
            weChetPerf = new App.Campaigns.Show.ArticleWeChat
              collection: article.get("wechat_performance")
              disabled: true
              canUpload = false
            articleDialog.showChildView 'weChat', weChetPerf
        error: (e)->
          console.log e
      Robin.modal.show articleDialog

    serializeData: () ->
      data = @model.toJSON()
      accepted = _.chain(data.campaign_invites)
        .filter (i) ->
          i.status == "A"
        .map (i) ->
          kol = _(data.kols).find (k) -> k.id == i.kol_id
          article = _(data.articles).find (a) -> a.kol_id == i.kol_id
          if not article?
            console.log "that is not ok, no article for invitation #{i.id}"
            article = {}
          kol.article = article
          kol
        .value()
      {
        campaign: data
        accepted: accepted
      }

  Show.CampaignDeclined = Backbone.Marionette.ItemView.extend
    template: 'modules/smart-campaign/show/templates/campaign_details/campaign-declined'

    templateHelpers:
      formatDate: (d) ->
        date = new Date d
        monthNum = parseInt(date.getMonth()) + 1
        date.toLocaleFormat '%d-' + polyglot.t('date.monthes_abbr.m' + monthNum) + '-%Y'
      timestamp: (d) ->
        date = new Date d
        date.getTime()
      public: (k) ->
        if k.is_public then polyglot.t('smart_campaign.yes') else polyglot.t('smart_campaign.no')
      status: (k) ->
        if k.status == "" then polyglot.t('smart_campaign.unknown') else polyglot.t('smart_campaign.declined')
      code: (k) ->
        if k.article? and k.article.tracking_code? and k.article.tracking_code != 'Waiting' and k.article.tracking_code != 'Negotiating'
          link = "http://#{window.location.host}/articles/#{k.article.tracking_code}"
          "<a href=\"#{link}\">#{link}</a>"
        else
          polyglot.t('smart_campaign.not_approved_yet')
      code_status: (k) ->
        if k.article? and k.article.tracking_code? and k.article.tracking_code == 'Waiting'
          polyglot.t('smart_campaign.pending_approval')
        else if k.article? and k.article.tracking_code? and k.article.tracking_code == 'Negotiating'
          polyglot.t('dashboard_kol.campaigns_tab.negotiating')
        else if k.article? and k.article.tracking_code? and k.article.tracking_code != 'Waiting'
          polyglot.t('smart_campaign.approved')
        else
          polyglot.t('smart_campaign.in_progress')

    events:
      "click tr.preview": "preview"

    preview: (e) ->
      id = $(e.currentTarget).data "article-id"
      article = new Robin.Models.Article
        campaign_model: @model
        id: id
        canUpload: false
      articleDialog = new App.Campaigns.Show.ArticleDialog
        model: article
        title: @model.get("name")
        disabled: true
        onApprove: (code) ->
          $("#code_#{id}").html code
          $("#code_status_#{id}").html 'Approved'
      article.fetch
        success: ()->
          articleDialog.render()
          article.fetch_comments ()->
            commentsList = new App.Campaigns.Show.ArticleComments
              collection: article.get("article_comments")
            articleDialog.showChildView 'comments', commentsList
          article.fetch_wechat_perf ()->
            weChetPerf = new App.Campaigns.Show.ArticleWeChat
              collection: article.get("wechat_performance")
              disabled: true
              canUpload = false
            articleDialog.showChildView 'weChat', weChetPerf
        error: (e)->
          console.log e
      Robin.modal.show articleDialog

    serializeData: () ->
      data = @model.toJSON()
      declined = _.chain(data.campaign_invites)
        .filter (i) ->
          i.status == "" or i.status == "D"
        .map (i) ->
          kol = _(data.kols).find (k) -> k.id == i.kol_id
          kol.status = i.status
          kol
        .value()
      {
        campaign: data
        declined: declined
      }
