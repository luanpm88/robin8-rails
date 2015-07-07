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
      public: (k) ->
        if k.is_public then "Yes" else "No"

    initialize: () ->
      @kols = []

    serializeData: () ->
      kols: @kols

    invitedKols: () ->
      _.chain(@kols)
        .filter (k) ->
          k.invited? and k.invited == true
        .pluck 'id'
        .value()

    updateKols: (data) ->
      invited_kols = @invitedKols()
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
      @validate()

    validate: () ->
      is_valid = _(@kols).any (k) -> k.invited? and k.invited == true
      if not is_valid
        $(".kol-header").addClass "error"
        $(".kol-errors").show()
      else
        $(".kol-header").removeClass "error"
        $(".kol-errors").hide()
      is_valid

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
      save: "#save-btn"
      form: "#campaign-form"

    events:
      "change @ui.categories": "categoriesChange"
      "change @ui.select": "releaseSelected"
      "click @ui.save": "save"

    onRender: () ->
      @showChildView 'targets', @targets_view
      @$el.find("#deadline").datepicker
        dateFormat: "D, d M y"
      @ui.form.validator()
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

    save: () ->
      kols_valid = @targets_view.validate()
      @ui.form.validator('validate')
      form_valid = $(".form-group.has-errors").length == 0
      if form_valid and kols_valid
        data = _.reduce @ui.form.serializeArray(), ((m, i) -> m[i.name] = i.value; m), {}
        data["kols"] = @targets_view.invitedKols()
        model = new Robin.Models.Campaign()
        model.save data,
          success: (m) ->
            location.href = "/#smart_campaign"

    serializeData: () ->
      releases: @releases
