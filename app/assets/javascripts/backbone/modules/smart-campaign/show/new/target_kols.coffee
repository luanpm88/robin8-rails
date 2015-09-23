Robin.module 'SmartCampaign.Show', (Show, App, Backbone, Marionette, $, _) ->

  Show.KolCategoriesTemplate = _.template '<span class="kol‐category"><%= label %></span>'

  Show.TargetKols = Backbone.Marionette.ItemView.extend
    template: 'modules/smart-campaign/show/templates/target-kols'
    ui:
      table: "#kols-table"
      ageGroup: "input[name=ageGroup]"
      male: "input[name=male]"
      regions: "input[name=regions]"
      content: "input[name=content]"
      locations: "input[id=locations]"
      invite_kol: "input[class=css-checkbox]"

    events:
      'change @ui.invite_kol': 'selectKol'
      'change @ui.ageGroup': 'changedAgeGroup'
      'change @ui.male': 'changedMale'
      'change @ui.regions': 'changedRegions'
      'change @ui.content': 'changedContent'

    templateHelpers:
      categories: (k) ->
        res = _(k.categories).map (c) ->
          context = { label: c.label }
          Show.KolCategoriesTemplate context
        res.join ''
      public: (k) ->
        if k.is_public then polyglot.t('smart_campaign.no') else polyglot.t('smart_campaign.yes')
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
        kols_id = []
        if invited_kols?
          $(invited_kols).each(() ->
            kols_id.push(this.id)
          )
        if invited_kols?
          isChecked = kols_id.indexOf(k.id)
        if isChecked >=0 then true else false

    initialize: (model) ->
      @kols = []
      @model = model

    serializeData: () ->
      kols: @kols,
      model: @model
      search: if @options.search then @options.search else false

    onRender: () ->
      @ui.table.DataTable
        info: false
        searching: false
        lengthChange: false
        pageLength: 25
        language:
          paginate:
            previous: polyglot.t('smart_campaign.prev'),
            next: polyglot.t('smart_campaign.next')
      if @model.model.get("kols")?
        $(".kol-header").removeClass "error"
        $(".kol-errors").hide()
      @$el.find('input[id=\'icheckbox_flat\']').iCheck
        checkboxClass: 'icheckbox_square-blue'
        increaseArea: '20%'
      $("#locations").geocomplete()

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
      kols_id = []
      if not @model.model.get("kols")?
        @model.model.set("kols",[])
      else
        influencers = @model.model.get("kols")
      if influencers.length > 0
          $(influencers).each(() ->
            kols_id.push(this.id)
          )

      index = kols_id.indexOf(kol.id)
      if index >= 0
        influencers.splice(index, 1)
        @model.model.set("kols",influencers)
        $(document.getElementsByName(e.target.name)).each ->
          @checked = false
          @value = "NO"
      else
        influencers.push kol
        @model.model.set("kols",influencers)
        $(document.getElementsByName(e.target.name)).each ->
          @checked = true
          @value = "YES"

      @validate()
      if @model.model.get("kols").length > 0
        document.getElementById("next-step").disabled = false
      else
        document.getElementById("next-step").disabled = true

    changedAgeGroup: (e) ->
      target = $ e.currentTarget
    changedMale: (e) ->
      target = $ e.currentTarget
    changedRegions: (e) ->
      target = $ e.currentTarget
    changedRegions: (e) ->
      target = $ e.currentTarget

    validate: () ->
      is_valid = _(@kols).any (k) -> k.invited? and k.invited == true
      if not is_valid
        $(".kol-header").addClass "error"
        $(".kol-errors").show()
      else
        $(".kol-header").removeClass "error"
        $(".kol-errors").hide()
      is_valid
