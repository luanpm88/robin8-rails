Robin.module 'SmartCampaign.Show', (Show, App, Backbone, Marionette, $, _) ->

  Show.KolCategoriesTemplate = _.template '<span class="kol‐category"><%= label %></span>'

  Show.KolInspectLayout = Marionette.LayoutView.extend
    template: 'modules/smart-campaign/show/templates/kol-inspect-layout',
    regions:
      statsRegion: '#kol-stats'
    className: 'modal-dialog'

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
      'click #apply-filter': 'applyFilter'
      'click #inspect': "showKolStats"

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
      @initial_kols = _(@model.model.get("kols")).pluck "id"

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

    showKolStats: (e) ->
      e.preventDefault()
      self = this

      target = $ e.currentTarget
      kol_id = target.data 'kol-id'
      kol = _(@kols).find (k) -> k.id == kol_id

      layout = new Show.KolInspectLayout
      Robin.modal.show layout

      kol_collection = new Backbone.Collection(kol)
      kolStatItemView = new Show.KolStatsView
        kol: kol
      layout.statsRegion.show kolStatItemView

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
      @kols = _(data).filter (k) =>
        @initial_kols.indexOf(k.id) == -1
      .map (k) ->
        if _.contains(invited_kols, k.id)
          k.invited = true
          k
        else
          k

    applyFilter: () ->
      channels = []
      wechat_personal = ""
      wechat_public = ""
      $('input[id=icheckbox_flat]').each (index, value) ->
        if $(this).is(':checked')
          if $(this).attr('name') == 'wechat_personal'
            wechat_personal = 'true'
          else if $(this).attr('name') == 'wechat_public'
            wechat_public = 'true'
          else
            channels.push $(this).attr('name')
      ageFilter = []
      $.each $('input[name=\'ageGroup\']:checked'), ->
        ageFilter.push $(this).attr('id')
      location = $('#locations').val()
      contentFilter = []
      $.each $('input[name=\'content\']:checked'), ->
        contentFilter.push $(this).attr('id')
      regions = []
      $.each $('input[name=\'regions\']:checked'), ->
        regions.push $(this).attr('id')
      male = []
      $.each $('input[name=\'male\']:checked'), ->
        male.push $(this).attr('value')
      categories = @model.model.get('iptc_categories')
      content_offline = ""
      content_online = ""
      $.each $('input[name=\'content\']:checked'), ->
        if $(this).attr('id') == 'online'
          content_online = 'true'
        if $(this).attr('id') == 'offline'
          content_offline = 'true'

      $.get "/kols/suggest/", {channels: channels, ageFilter: ageFilter, location: location, contentFilter: contentFilter, regions: regions, male: male, categories: categories, wechat_personal: wechat_personal, wechat_public: wechat_public, content_online:  content_online, content_offline:  content_offline}, (data) =>
        @updateKols data
        @render()
      if @model.model.get("kols")?
        if @model.model.get("kols").length > 0
          $('#next-step').removeAttr('disabled')
      else if @model.model.get("weibo")?
        if @model.model.get("weibo").length > 0
          $('#next-step').removeAttr('disabled')

    selectKol: (e) ->
      target = $ e.currentTarget
      kol_id = target.data 'kol-id'
      kol_status = target.is ':checked'
      kol = _(@kols).find (k) -> k.id == kol_id
      kol.invited = kol_status
      @model.model.set "kols", _(@kols).filter (k) ->
        k.invited? and k.invited == true
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
