Robin.module 'SmartCampaign.Show', (Show, App, Backbone, Marionette, $, _)->

  Show.TargetKols = Backbone.Marionette.ItemView.extend
    template: 'modules/smart-campaign/show/templates/target-kols'
    ui:
      table: "#kols-table"
    initialize: () ->
      @kols = []
    serializeData: () ->
      kols: @kols
    onRender: () ->
      @ui.table.stupidtable()

  Show.NewCampaign = Backbone.Marionette.LayoutView.extend
    template: 'modules/smart-campaign/show/templates/new-campaign'

    regions:
      targets: "#target-kols"

    initialize: (opts) ->
      @targets_view = new Show.TargetKols()
      @releases = _(opts.releases or []).pluck 'release'

    ui:
      categories: "#categories"
      select: "select"

    events:
      "change @ui.categories": "categoriesChange"

    onRender: () ->
      @showChildView 'targets', @targets_view
      @ui.categories.select2
        placeholder: "Select campaign categories"
        multiple: true
        minimumInputLength: 1
        maximumSelectionSize: 10
        ajax:
          url: "/kols/suggest_categories"
          dataType: 'json'
          quietMillis: 250
          data: (term) ->
            f: term
          results: (data) ->
            results: data
          cache: true
        escapeMarkup: _.identity

    categoriesChange: () ->
      $.get "/kols/suggest/", {categories: @ui.categories.val()}, (data) =>
        @targets_view.kols = data
        @targets_view.render()

    serializeData: () ->
      console.log @releases
      releases: @releases
