Robin.module 'SmartCampaign.Show', (Show, App, Backbone, Marionette, $, _) ->

  Show.TargetsTabAnalytics = Marionette.LayoutView.extend
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

    initialize: (model) ->
      @model = model
      @wechat_view = new Show.TargetKols()
#      @weibo_view = new Show.TargetKols()
      @targets_view = new Show.TargetKols()
#      @search_view = new Show.TargetKols()

    categoriesChange: () ->
      iptc_categories = @model.iptc_categories
      $.get "/kols/suggest/", {categories: iptc_categories}, (data) =>
        @targets_view.updateKols data
        @targets_view.render()

    releaseSelected: () ->
      #id = parseInt @ui.select.val()
      #r = _(@releases).find (x) -> x.id == id
      if r? and r.iptc_categories? and r.iptc_categories.length > 0
        selected = @ui.categories.val().split(',')
        _.chain(r.iptc_categories)
        .filter (c) ->
          not _.contains(selected, c)
        .each (c) =>
          $.get "/autocompletes/category/", { id: c }, (data) =>
            old = @ui.categories.select2 'data'
            old.push data
            @ui.categories.select2 'data', old
            @categoriesChange()

    onRender: () ->
      @showChildView 'wechatRegion', @wechat_view
#      @showChildView 'weiboRegion', @weibo_view
      @showChildView 'blogsRegion', @targets_view
#      @showChildView 'searchRegion', @search_view
      iptc_categories = @model.get('iptc_categories')
      $.get "/kols/suggest/", {categories: iptc_categories}, (data) =>
        @targets_view.updateKols data
        @targets_view.render()
