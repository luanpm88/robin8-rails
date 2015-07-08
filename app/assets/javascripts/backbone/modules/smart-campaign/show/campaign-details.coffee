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

    events:
      "click span.preview": "preview"

    preview: (e) ->
      id = $(e.currentTarget).data "article-id"
      alert "preview for article #{id}"

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
          kol.article = article
          kol
        .value()
      {
        campaign: data
        accepted: accepted
        declined: declined
      }
