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
#       @wechat_view = new Show.TargetKols()
#      @weibo_view = new Show.TargetKols()
      @targets_view = new Show.TargetKols(
        model: @model
      )
      @search_view = new Show.SearchLayout(
        model: @model
      )
      @wechat_view = new Show.TargetWechat()
      @weibo_view = new Show.TargetWeibo()

    openPitchTab: () ->
      @options.parent.setState('pitch')

    onRender: () ->
      @showChildView 'wechatRegion', @wechat_view
      @showChildView 'weiboRegion', @weibo_view
      @showChildView 'blogsRegion', @targets_view
      @showChildView 'searchRegion', @search_view

      iptc_categories = @model.get('iptc_categories')
      kols = @model.get('kols')
      $.get "/kols/suggest/", {categories: iptc_categories}, (data) =>
        @targets_view.updateKols data
        @targets_view.render()
