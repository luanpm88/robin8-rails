Robin.module 'SmartCampaign.Show', (Show, App, Backbone, Marionette, $, _)->

  Show.CampaignDetails = Backbone.Marionette.ItemView.extend
    template: 'modules/smart-campaign/show/templates/campaign-details'

    templateHelpers:
      formatDate: (d) ->
        date = new Date d
        date.toLocaleFormat '%d-%b-%Y'
      timestamp: (d) ->
        date = new Date d
        date.getTime()
      public: (k) ->
        if k.is_public then "Yes" else "No"
      status: (k) ->
        if k.status == "" then "Unknown" else "Declined"
      code: (k) ->
        if k.article? and k.article.tracking_code?
          k.article.tracking_code
        else
          "Not approved yet"

    events:
      "click tr.preview": "preview"

    preview: (e) ->
      id = $(e.currentTarget).data "article-id"
      article = new Robin.Models.Article
        campaign_model: @model
        id: id
      articleDialog = new App.Campaigns.Show.ArticleDialog
        model: article
        title: @model.get("name")
        disabled: true
      article.fetch
        success: ()->
          articleDialog.render()
          article.fetch_comments ()->
            commentsList = new App.Campaigns.Show.ArticleComments
              collection: article.get("article_comments")
            articleDialog.showChildView 'comments', commentsList
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
        declined: declined
      }
