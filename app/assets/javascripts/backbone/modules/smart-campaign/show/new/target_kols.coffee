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
      kols_id: ()->
        invited_kols = @model.model.get("kols")
        kols_id = []
        if invited_kols?
          $(invited_kols).each(() ->
            kols_id.push(this.id)
          )
        return kols_id
      campaign_id: ()->
        @model.model.get("id")
      isPresent: (k, campaign_id, kols_id) ->
        isShow = -1
        if (kols_id.length >0) && campaign_id?
          isShow = kols_id.indexOf(k.id)
        if isShow < 0 then true else false
      isChecked: (k, kols_id) ->
        isChecked = -1
        invited_kols = @model.model.get("kols")
        if invited_kols?
          isChecked = invited_kols.indexOf(k.id)
        if isChecked >=0 then true else false

    initialize: (model) ->
      @kols = []
      @model = model

    serializeData: () ->
      kols: @kols,
      model: @model

    kols_id: ()->
      invited_kols = @model.model.get("kols")
      kols_id = []
      if invited_kols?
        $(invited_kols).each(() ->
          kols_id.push(this.id)
        )
      return kols_id
    campaign_id: ()->
      @model.model.get("id")

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
      influencers = []
      if not @model.model.get("kols")?
        @model.model.set("kols",[])
      else
        influencers = @model.model.get("kols")


      index = influencers.indexOf(kol)
      if index >= 0
        influencers.splice(index, 1)
        $(document.getElementsByName(e.target.name)).each ->
          @checked = false
          @value = "NO"
      else
        influencers.push kol
        $(document.getElementsByName(e.target.name)).each ->
          @checked = true
          @value = "YES"

      @model.model.set("kols",influencers)
      @validate()
      if influencers.length > 0
        document.getElementById("next-step").disabled = false
      else
        document.getElementById("next-step").disabled = true

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
      if @model.model.get("kols")?
        $(".kol-header").removeClass "error"
        $(".kol-errors").hide()
        document.getElementById("next-step").disabled = false
