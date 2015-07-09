Robin.module 'Campaigns.Show', (Show, App, Backbone, Marionette, $, _)->

  Show.CampaignsLayout = Backbone.Marionette.LayoutView.extend
    template: 'modules/campaigns/show/templates/layout'
    regions:
      accepted: "#accepted"
      declined: "#declined"

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
        if campaign.tracking_code?
          campaign.tracking_code
        else
          "Not approved yet"

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
        error: (e)->
          console.log e
      articleDialog = new Show.ArticleDialog
        model: article
        title: model.get("name")
      Robin.modal.show articleDialog

    serializeData: () ->
      items: @collection.toJSON()
      declined: @options.declined

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
