Robin.module 'DashboardKol.Show', (Show, App, Backbone, Marionette, $, _) ->

  target =
    ages: ['<12', '12-18', '12-25', '25-35', '35-45', '45-55', '>55']
    regions: ['east', 'north', 'northeast', 'south', 'west', 'central']
    mf: ['80:20', '60:40', '50:50', '40:60', '20:80']
    industries: ['Industry 1', 'Industry 2 ', 'Industry 3',
      'Industry 4','Industry 5']
    genders:
      0: 'secrecy'
      1: 'male'
      2: 'female'

  kol_fields_mapping =
    genders: 'gender'
    mf: 'audience_gender_ratio'
    ages: 'audience_age_groups'
    regions: 'audience_regions'

  kol_fields_mapping_i = _.invert kol_fields_mapping

  Show.ProfileTab = Backbone.Marionette.LayoutView.extend
    template: 'modules/dashboard-kol/show/templates/profile-tab'

    ui:
      birthdate: "#birthdate"

    regions:
      social: ".social-content"

    templateHelpers:
      checked: (key, index, kol) ->
        v = kol[kol_fields_mapping[key]]
        return 'checked="checked"' if target[key][index] == v
        return ""
      active: (key, index, kol) ->
        v = _.chain(kol[kol_fields_mapping[key]].split '|').map (x) ->
          x.trim()
        .filter (x) ->
          x != ""
        .value()
        return "active" if target[key][index] in v
        return ""

    initialize: (opts) ->
      @target = target
      @model = App.currentKOL
      @model_binder = new Backbone.ModelBinder()

    onRender: ->
      @model_binder.bind @model, @el
      @social_view = new Show.ProfileSocialView
        model: @model
      @showChildView 'social', @social_view
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

    serializeData: ->
      _.extend @target,
        k: @model.toJSON()

