Robin.module 'DashboardKol.Show', (Show, App, Backbone, Marionette, $, _) ->

  target =
    ages: ['<12', '12-18', '12-25', '25-35', '35-45', '45-55', '>55']
    regions: ['east', 'north', 'northeast', 'south', 'west', 'central']
    mf: ['80:20', '60:40', '50:50', '40:60', '20:80']
    industries: ['Industry1', 'Industry2 ', 'Industry3',
      'Industry4','Industry5']
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
      industry: '#industry'

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
      @initSelect2()
      @$el.find('input[type=radio][checked]').prop('checked', 'checked')  # I❤js

    initSelect2: ->
      @ui.industry.select2
        maximumSelectionSize: 5
        tokenSeparators: [' ']
        tags: @target.industries
        separator: '|'
        width: '100%'
        placeholder: polyglot.t('dashboard_kol.profile_tab.industry_placeholder')
      @ui.industry.val(@model.get 'industry').trigger('change')
      @$el.find('.industry-row button').click (e) =>
        _.defer -> $(e.target).removeClass('active').blur()
        index = parseInt e.target.name.split('_')[1]
        new_val = @target.industries[index]
        old_val = _.compact @ui.industry.val().split('|')
        if (not (new_val in old_val)) and old_val.length < 5
          old_val.push new_val
          @ui.industry.val(old_val.join '|').trigger 'change'

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

    save: ->
      return if not @validate()
      @pickFields()
      @model_binder.copyViewValuesToModel()
      window.debug_view = @

