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
        error: (e)->
          console.log e
      articleDialog = new Show.ArticleDialog
        model: article
        title: model.get("name")
      Robin.modal.show articleDialog

    serializeData: ()->
      items: @collection.toJSON()
      declined: @options.declined
