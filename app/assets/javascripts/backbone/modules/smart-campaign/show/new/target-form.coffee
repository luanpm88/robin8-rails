Robin.module 'SmartCampaign.Show', (Show, App, Backbone, Marionette, $, _) ->

  Show.TargetTab = Marionette.LayoutView.extend
    template: 'modules/smart-campaign/show/templates/start-tab-targets'

    ui:
      categories: "#categories"
      select: "select.releases"
      nextButton: '#next-step'

    regions:
      wechatRegion: "#targets-wechat"
      weiboRegion: "#targets-weibo"
      blogsRegion: "#targets-blogs"
      searchRegion: "#targets-search"

    events:
      'click @ui.nextButton': 'openPitchTab'

    initialize: (options) ->
      @model = if @options.model? then @options.model else new Robin.Models.Campaign()
      @weibo_view = new Show.TargetWeibo(
        model: @model
      )
      @targets_view = new Show.TargetKols(
        model: @model
      )
      @search_view = new Show.SearchLayout(
        model: @model
      )
      @wechat_view = new Show.TargetWechat()


    openPitchTab: () ->
      @options.parent.setState('pitch')

    onRender: () ->

      self = this

      @showChildView 'wechatRegion', @wechat_view
      @showChildView 'weiboRegion', @weibo_view
      @showChildView 'blogsRegion', @targets_view
      @showChildView 'searchRegion', @search_view

      iptc_categories = @model.get('iptc_categories')
      $.get "/kols/suggest/", {categories: iptc_categories}, (data) =>
        @targets_view.updateKols data
        @targets_view.render()
      if @model.get("kols")?
        if @model.get("kols").length > 0
          @ui.nextButton.removeAttr('disabled')


      params = {description: @model.get("description")}
      $.ajax({
        dataType: 'json',
        method: 'POST',
        url: '/campaign/get_counter/',
        data: params,
        async:   false
        success: (response)->
          self.model.set("counter", response)
      })

      params = {title: @model.get("name"), body: @model.get("description"), per_page: 100, included_email: true, type: "weibo", published_at: "[* TO *]"}
      $.post "/robin8_api/suggested_authors", {title: @model.get("name"), body: @model.get("description"), per_page: 100, included_email: true, type: "weibo", published_at: "[* TO *]"}, (data) =>
        @weibo_view.updateWeibo data
        @weibo_view.setCampaignModel @model
        @weibo_view.render()



    transformLabel: (label, code) ->
      if code.substring(0, 2) == "16"
        label = "Society - Issue"

      if code == "12001000"
        label = "Arts, Culture and Entertainment - Culture"

      return label
