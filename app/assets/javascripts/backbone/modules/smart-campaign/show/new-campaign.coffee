Robin.module 'SmartCampaign.Show', (Show, App, Backbone, Marionette, $, _)->

  Show.KolCategoriesTemplate = _.template '<span class="kol-category"><%= label %></span>'

  Show.TargetKols = Backbone.Marionette.ItemView.extend
    template: 'modules/smart-campaign/show/templates/target-kols'
    ui:
      table: "#kols-table"
    events:
      'change input': 'selectKol'

    templateHelpers:
      categories: (k) ->
        res = _(k.iptc_categories).map (c) ->
          context = { label: c.label }
          Show.KolCategoriesTemplate context
        res.join ''

    initialize: () ->
      @kols = []

    serializeData: () ->
      kols: @kols

    updateKols: (data) ->
      invited_kols = _.chain(@kols)
        .filter (k) ->
          k.invited? and k.invited == true
        .pluck 'id'
        .value()
      @kols = _(data).map (k) ->
        if _.contains(invited_kols, k.id)
          k.invited = true
          k
        else
          k

    selectKol: (e) ->
      target = $ e.currentTarget
      kol_id = target.data 'kol-id'
      kol_status = target.is ':checked'
      kol = _(@kols).find (k) -> k.id == kol_id
      kol.invited = kol_status

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
      select: "select.releases"

    events:
      "change @ui.categories": "categoriesChange"
      "change @ui.select": "releaseSelected"

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
        @targets_view.updateKols data
        @targets_view.render()

    releaseSelected: () ->
      id = parseInt @ui.select.val()
      r = _(@releases).find (x) -> x.id == id
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

    serializeData: () ->
      releases: @releases
