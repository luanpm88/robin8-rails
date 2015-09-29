Robin.module 'DashboardKol.Show', (Show, App, Backbone, Marionette, $, _) ->

  target =
    ages: ['<12', '12-18', '18-25', '25-35', '35-45', '45-55', '>55']
    regions: ['east', 'north', 'northeast', 'south', 'west', 'central']
    mf: ['80:20', '60:40', '50:50', '40:60', '20:80']
    industries:
      "01021000": "entertainment"
      "01022000": "culture"
      "04017000": "economy"
      "04018000": "business"
      "13010000": "technology"
    genders:
      0: 'secrecy'
      1: 'male'
      2: 'female'

  kol_fields_mapping =
    genders: 'gender'
    mf: 'audience_gender_ratio'
    ages: 'audience_age_groups'
    regions: 'audience_regions'

  Show.ProfileTab = Backbone.Marionette.LayoutView.extend
    template: 'modules/dashboard-kol/show/templates/profile-tab'

    ui:
      birthdate: "#birthdate"
      next: '#back_to_score_btn'
      industry: '#interests'

    regions:
      social: ".social-content"

    events:
      'click @ui.next': 'save'

    templateHelpers:
      checked: (key, index, kol) ->
        v = kol[kol_fields_mapping[key]]
        return 'checked="checked"' if target[key][index] == v
        return 'checked="checked"' if key == 'genders' and "#{index}" == "#{v}"
        return ""
      active: (key, index, kol) ->
        v = _.chain(kol[kol_fields_mapping[key]].split '|').map (x) ->
          x.trim()
        .compact().value()
        return "active" if target[key][index] in v
        return ""

    initialize: (opts) ->
      @target = target
      @model = new Robin.Models.KolProfile App.currentKOL.attributes
      @model_binder = new Backbone.ModelBinder()
      @initial_attrs = @model.toJSON()
      @parent_view = opts.parent

    onRender: ->
      @model_binder.bind @model, @el
      @social_view = new Show.ProfileSocialView
        model: @model
      @showChildView 'social', @social_view
      @initSelect2()
      @initDatepicker()
      @$el.find('input[type=radio][checked]').prop('checked', 'checked')  # I❤js
      _.defer ->
        crs.init()

    initDatepicker: ->
      monthes = []
      monthesShort = []
      daysMin = []
      days = []
      for i in [0..11]
        monthes[i] = polyglot.t('date.monthes_full.m' + (i + 1))
        monthesShort[i] = polyglot.t('date.monthes_abbr.m' + (i + 1))
      for i in [0..6]
        days[i] = polyglot.t('date.days_full.d' + (i + 1))
        daysMin[i] = polyglot.t('date.datepicker_days.d' + (i + 1))
      @ui.birthdate.datepicker
        monthNames: monthes
        monthNamesShort: monthesShort
        dayNames: days
        dayNamesMin: daysMin
        nextText: polyglot.t('date.datepicker_next')
        prevText: polyglot.t('date.datepicker_prev')
        dateFormat: "D, d M y"
      if @model.get('date_of_birthday')?
        @ui.birthdate.datepicker("setDate", new Date(@model.get('date_of_birthday')))


    initSelect2: ->
      @ui.industry.select2
        maximumSelectionSize: 5
        multiple: true
        minimumInputLength: 1
        width: '100%'
        placeholder: polyglot.t('dashboard_kol.profile_tab.industry_placeholder')
        ajax:
          url: '/kols/suggest_categories'
          dataType: 'json'
          data: (term, page) ->
            return { f: term }
          results:  (data, page) ->
            return { results: data }
          cache:true
        escapeMarkup: _.identity
        initSelection: (el, callback) ->
          $("#interests").val ''
          $.get "/kols/current_categories", (data) ->
            callback data

      @$el.find('.industry-row button').click (e) =>
        _.defer -> $(e.target).removeClass('active').blur()

    serializeData: ->
      _.extend @target,
        k: @model.toJSON()

    validate: ->
      return true

    pickFields: ->
      set_multi_value = (field) =>
        v = _.chain(@$el.find(".#{field}-row button.active")).map (el) ->
          el.name.split('_')[1]
        .map (x) ->
          target[field][x]
        .compact().value().join('|')
        @model.set kol_fields_mapping[field], v
      set_multi_value 'ages'
      set_multi_value 'regions'
      gender_ratio_i = _.find($("input[type=radio][name=mf]"), (el) -> el.checked).value.split('_')[1]
      v = @target['mf'][gender_ratio_i]
      @model.set kol_fields_mapping['mf'], v

    save: ->
      return if not @validate()
      @pickFields()
      @model_binder.copyViewValuesToModel()
      return if @model.toJSON() == @initial_attrs
      @model.save @model.attributes,
        success: (m, r) =>
          @initial_attrs = m.toJSON()
          App.currentKOL.set m.attributes
          $.growl "You profile was saved successfully", {type: "success"}
          @parent_view?.score()
        error: (m, r) =>
          console.log "Error saving KOL profile. Response is:"
          console.log r
          $.growl "Can't save profile info", {type: "danger"}

