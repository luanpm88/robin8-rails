Robin.module 'SmartCampaign.Show', (Show, App, Backbone, Marionette, $, _)->

  Show.TargetKols = Backbone.Marionette.ItemView.extend
    template: 'modules/smart-campaign/show/templates/target-kols'
    initialize: () ->
      @kols = []
    serializeData: () ->
      kols: @kols

  Show.NewCampaign = Backbone.Marionette.LayoutView.extend
    template: 'modules/smart-campaign/show/templates/new-campaign'

    regions:
      targets: "#target-kols"

    initialize: () ->
      @targets_view = new Show.TargetKols()

    ui:
      categories: "#categories"

    events:
      "change @ui.categories": "categoriesChange"

    onRender: () ->
      console.log "rendering again"
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


