Robin.module 'SmartCampaign.Show', (Show, App, Backbone, Marionette, $, _) ->

  Show.AuthorInspectLayout = Marionette.LayoutView.extend
    template: 'modules/smart-campaign/show/templates/author-inspect-layout',
    regions:
      statsRegion: '#author-stats',
      recentStoriesRegion: '#author-recent-stories',
      relatedStoriesRegion: '#author-related-stories'
    className: 'modal-dialog'


  Show.TargetWeibo = Backbone.Marionette.ItemView.extend
    template: 'modules/smart-campaign/show/templates/targets-tab-weibo'

    ui:
      table: "#weibo-table"
    events:
      'change input': 'selectWeibo'
      'click .inspect': 'openInspectModal'

    templateHelpers:
      weibo_id: ()->
        invited_weibo = @model.model.get("weibo")
        weibo_id = []
        if invited_weibo?
          $(invited_weibo).each(() ->
            weibo_id.push(this.id)
          )
        return weibo_id
      campaign_id: ()->
        @model.model.get("id")
      isPresent: (k, campaign_id, weibo_id) ->
        isShow = -1
        if (weibo_id.length >0) && campaign_id?
          isShow = weibo_id.indexOf(k.id)
        if isShow < 0 then true else false
      isChecked: (k, weibo_id) ->
        isChecked = -1
        invited_weibo = @model.model.get("weibo")
        weibo_id = []
        if invited_weibo?
          $(invited_weibo).each(() ->
            weibo_id.push(this.id)
          )
        if invited_weibo?
          isChecked = weibo_id.indexOf(k.id)
        if isChecked >=0 then true else false

    initialize: (model) ->
      @weibo = []
      @model = model

    serializeData: () ->
      weibo: @weibo,
      model: @model

    weibo_id: ()->
      invited_weibo = @model.model.get("weibo")
      weibo_id = []
      if invited_weibo?
        $(invited_weibo).each(() ->
          weibo_id.push(this.pressr_id)
        )
      return weibo_id

    campaign_id: ()->
      @model.model.get("id")

    invitedWeibo: () ->
      _.chain(@weibo)
      .filter (k) ->
        k.invited? and k.invited == true
      .pluck '[pressr_id]'
      .value()

    updateWeibo: (data) ->
      invited_weibo = @invitedWeibo()
      @weibo = _(data).map (k) ->
        if _.contains(invited_weibo, k.pressr_id)
          k.invited = true
          k
        else
          k

    selectWeibo: (e) ->
      target = $ e.currentTarget
      weibo_id = target.data 'weibo-id'
      weibo_status = target.is ':checked'
      weibo = _(@weibo).find (k) -> k.id == weibo_id
      weibo.invited = weibo_status
      influencers = []
      weibo_id = []
      if not @model.model.get("weibo")?
        @model.model.set("weibo",[])
      else
        influencers = @model.model.get("weibo")
      if influencers.length > 0
        $(influencers).each(() ->
          weibo_id.push(this.id)
        )

      index = weibo_id.indexOf(weibo.id)
      if index >= 0
        influencers.splice(index, 1)
        @model.model.set("weibo",influencers)
        $(document.getElementsByName(e.target.name)).each ->
          @checked = false
          @value = "NO"
      else
        influencers.push weibo
        @model.model.set("weibo",influencers)
        $(document.getElementsByName(e.target.name)).each ->
          @checked = true
          @value = "YES"

      @validate()
      if @model.model.get("weibo").length > 0
        document.getElementById("next-step").disabled = false
      else
        document.getElementById("next-step").disabled = true

    validate: () ->
      is_valid = _(@weibos).any (k) -> k.invited? and k.invited == true
      if not is_valid
        $(".weibo-header").addClass "error"
        $(".weibo-errors").show()
      else
        $(".weibo-header").removeClass "error"
        $(".weibo-errors").hide()
      is_valid

    onRender: () ->
      @ui.table.DataTable
        info: false
        searching: false
        lengthChange: false
        pageLength: 25
      if @model.model.get("weibo")?
        $(".weibo-header").removeClass "error"
        $(".weibo-errors").hide()

    setCampaignModel: (model) ->
      @campaignModel = model


    openInspectModal: (e) ->
      e.preventDefault()
      self = this

      target = $ e.currentTarget
      weibo_id = target.data 'weibo-id'
      weibo = _(@weibo).find (k) -> k.id == weibo_id
      weibo_model = new Robin.Models.Author {full_name: weibo.full_name, id: weibo.id }

      layout = new Show.AuthorInspectLayout
        model: weibo_model

      Robin.modal.show layout

      relatedStoriesCollection = new Robin.Collections.RelatedStories
        author_id: weibo_model.get('id'),
        releaseModel: @campaignModel

      layout.relatedStoriesRegion.show new Robin.Components.Loading.LoadingView
          className: 'stories-loading-container'

      relatedStoriesCollection.fetchWeiboStories({
        success: (collection, data, response) ->
          relatedStoriesView = new Show.StoriesList
            collection: collection
          layout.relatedStoriesRegion.show relatedStoriesView
      })

      recentStoriesCollection = new Robin.Collections.RecentStories
        author_id: weibo_model.get('id'),
        releaseModel: @campaignModel

      layout.recentStoriesRegion.show new Robin.Components.Loading.LoadingView
          className: 'stories-loading-container'

      recentStoriesCollection.fetchWeiboStories({
        success: (collection, data, response) ->
          recentStoriesView = new Show.StoriesList
            collection: collection
          layout.recentStoriesRegion.show recentStoriesView
        })

      authorStatsModel = new Robin.Models.AuthorWeiboStats { id: weibo_model.id }
      layout.statsRegion.show new Robin.Components.Loading.LoadingView

      authorStatsModel.fetch({
        success: (model, response, options) ->
          authorStatItemView = new Show.AuthorStatsView
            model: model,
            authorModel: weibo_model,
            campaignModel: self.campaignModel
          layout.statsRegion.show authorStatItemView
      })
