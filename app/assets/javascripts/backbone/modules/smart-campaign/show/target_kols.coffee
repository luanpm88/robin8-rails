Robin.module 'SmartCampaign.Show', (Show, App, Backbone, Marionette, $, _) ->

  Show.KolCategoriesTemplate = _.template '<span class="kol‐category"><%= label %></span>'

  Show.TargetKols = Backbone.Marionette.ItemView.extend
    template: 'modules/smart-campaign/show/templates/target-kols'
    ui:
      table: "#kols-table"
    events:
      'change input': 'selectKol'

    templateHelpers:
      categories: (k) ->
        res = _(k.categories).map (c) ->
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
      @ui.table.DataTable
        info: false
        searching: false
        lengthChange: false
        pageLength: 25
