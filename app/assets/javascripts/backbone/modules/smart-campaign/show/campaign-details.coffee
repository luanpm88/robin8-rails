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
        d = date.getDate()
        y = date.getFullYear()
        month = polyglot.t('date.monthes_abbr.m' + monthNum)
        "#{d}-#{month}-#{y}"
      budget: (campaign) ->
        if campaign.non_cash == false
          "$ " + campaign.budget
        else
          polyglot.t('smart_campaign.non_cash')

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
      code_status: (k) ->
        if k.article? and k.article.tracking_code? and k.article.tracking_code != 'Waiting' and k.article.tracking_code != 'Negotiating'
          polyglot.t('smart_campaign.approved')
        else if k.article? and k.article.tracking_code? and k.article.tracking_code == 'Waiting'
          polyglot.t('smart_campaign.pending_approval')
        else
          polyglot.t('smart_campaign.in_progress')
      code: (campaign) ->
        if campaign.tracking_code? and campaign.tracking_code != 'Waiting' and campaign.tracking_code != 'Negotiating'
          link = "http://#{window.location.host}/articles/#{campaign.tracking_code}"
          "<a href=\"#{link}\">#{link}</a>"
        else
          polyglot.t('kol_campaign.not_approved_yet')
      formatDate: (d) ->
        date = new Date d
        monthNum = parseInt(date.getMonth()) + 1
        d = date.getDate()
        y = date.getFullYear()
        month = polyglot.t('date.monthes_abbr.m' + monthNum)
        "#{d}-#{month}-#{y}"

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
        no_comments: false
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
      oneDay = 24*60*60*1000
      end = Date.today()
      data = @model.toJSON()
      accepted = _.chain(data.campaign_invites)
        .filter (i) ->
          i.status == "A" and (Math.round(Math.abs(((new Date(data.deadline)).getTime() - end.getTime())/(oneDay))) > 0)
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
      status: (k) ->
        if k.status == "" then polyglot.t('smart_campaign.unknown') else polyglot.t('smart_campaign.rejected')
      formatDate: (d) ->
        date = new Date d
        monthNum = parseInt(date.getMonth()) + 1
        d = date.getDate()
        y = date.getFullYear()
        month = polyglot.t('date.monthes_abbr.m' + monthNum)
        "#{d}-#{month}-#{y}"

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
        no_comments: true
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
      oneDay = 24*60*60*1000
      end = Date.today()
      data = @model.toJSON()
      declined = _.chain(data.campaign_invites)
        .filter (i) ->
          i.status == "D" and (Math.round(Math.abs(((new Date(data.deadline)).getTime() - end.getTime())/(oneDay))) > 0)
        .map (i) ->
          kol = _(data.kols).find (k) -> k.id == i.kol_id
          kol.status = i.status
          kol.decline_date = if i.decline_date == undefined || i.decline_date == null then i.updated_at else i.decline_date
          kol
        .value()
      {
        campaign: data
        declined: declined
      }

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

  Show.CampaignNegotiating = Backbone.Marionette.ItemView.extend
    template: 'modules/smart-campaign/show/templates/campaign_details/campaign-negotiating'

    templateHelpers:
      status: (k) ->
        if k.article.tracking_code? and k.article.tracking_code != 'Waiting' and k.article.tracking_code == 'Negotiating'
          polyglot.t('smart_campaign.negotiating')
        else
          polyglot.t('smart_campaign.unknown')
      formatDate: (d) ->
        date = new Date d
        monthNum = parseInt(date.getMonth()) + 1
        d = date.getDate()
        y = date.getFullYear()
        month = polyglot.t('date.monthes_abbr.m' + monthNum)
        "#{d}-#{month}-#{y}"
      budget: (campaign) ->
        if campaign.non_cash == false
          "$ " + campaign.budget
        else
          campaign.description

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
        no_comments: false
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
      oneDay = 24*60*60*1000
      end = Date.today()
      data = @model.toJSON()
      negotiating = _.chain(data.articles)
        .filter (i) ->
          i.tracking_code == "Negotiating" and (Math.round(Math.abs(((new Date(data.deadline)).getTime() - end.getTime())/(oneDay))) > 0)
        .map (i) ->
          kol = _(data.kols).find (k) -> k.id == i.kol_id
          kol.status = i.tracking_code
          kol
        .value()
      {
        campaign: data
        negotiating: negotiating
      }

  Show.CampaignInvitedList = Backbone.Marionette.ItemView.extend
    template: 'modules/smart-campaign/show/templates/campaign_details/campaign-invited'

    templateHelpers:
      formatDate: (d) ->
        date = new Date d
        monthNum = parseInt(date.getMonth()) + 1
        d = date.getDate()
        y = date.getFullYear()
        month = polyglot.t('date.monthes_abbr.m' + monthNum)
        "#{d}-#{month}-#{y}"

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
        no_comments: true
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
      oneDay = 24*60*60*1000
      data = @model.toJSON()
      end = Date.today()
      invited = _.chain(data.campaign_invites)
        .filter (i) ->
          Math.round(Math.abs(((new Date(data.deadline)).getTime() - end.getTime())/(oneDay))) > 0
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
        invited: invited
      }
  Show.CampaignInterested = Backbone.Marionette.ItemView.extend
    template: 'modules/smart-campaign/show/templates/campaign_details/campaign-interested'

    templateHelpers:
      formatDate: (d) ->
        date = new Date d
        monthNum = parseInt(date.getMonth()) + 1
        d = date.getDate()
        y = date.getFullYear()
        month = polyglot.t('date.monthes_abbr.m' + monthNum)
        "#{d}-#{month}-#{y}"

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
        no_comments: true
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
      oneDay = 24*60*60*1000
      data = @model.toJSON()
      end = Date.today()
      category_labels = @options.category_labels
      interested = _.chain(data.campaign_invites)
        .filter (i) ->
          Math.round(Math.abs(((new Date(data.deadline)).getTime() - end.getTime())/(oneDay))) > 0
        .map (i) ->
          kol = _(data.kols).find (k) -> k.id == i.kol_id

          categories_id = _.map(data.kol_categories, (categories) ->
            if categories.kol_id == i.kol_id
              categories.iptc_category_id
          )
          categories_labels = _.map(category_labels, (categories) ->
            if categories_id.indexOf(categories.id) > -1
              return categories.text
          )
          if categories_labels.length != 0
            categories_labels = categories_labels.join()

          article = _(data.articles).find (a) -> a.kol_id == i.kol_id
          if not article?
            console.log "that is not ok, no article for invitation #{i.id}"
            article = {}
          kol.article = article
          kol.categories_labels = categories_labels
          kol
        .value()
      {
        campaign: data
        interested: interested
      }

  Show.CampaignHistory = Backbone.Marionette.ItemView.extend
    template: 'modules/smart-campaign/show/templates/campaign_details/campaign-history'

    templateHelpers:
      status: (k) ->
        if k.status == "D"
          polyglot.t('smart_campaign.declined')
        else if k.status == "A"
          polyglot.t('dashboard.accepted')
        else
          polyglot.t('smart_campaign.expired')
      formatDate: (d) ->
        date = new Date d
        monthNum = parseInt(date.getMonth()) + 1
        d = date.getDate()
        y = date.getFullYear()
        month = polyglot.t('date.monthes_abbr.m' + monthNum)
        "#{d}-#{month}-#{y}"

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
        no_comments: true
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
      oneDay = 24*60*60*1000
      data = @model.toJSON()
      end = Date.today()
      history = _.chain(data.campaign_invites)
        .filter (i) ->
          Math.round(Math.abs(((new Date(data.deadline)).getTime() - end.getTime())/(oneDay))) <= 0
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
        history: history
      }
