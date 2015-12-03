Robin.module 'DashboardKol.Show', (Show, App, Backbone, Marionette, $, _) ->
  target =
    genders:
      0: 'secrecy'
      1: 'male'
      2: 'female'

  kol_fields_mapping =
    genders: 'gender'

  Show.ProfileTab = Backbone.Marionette.LayoutView.extend
    template: 'modules/dashboard-kol/templates/profile-tab'
    ui:
      birthdate:  "#birthdate"
      datetimepicker: "#datetimepicker"
      calendar_button: ".calendar_button"
      next: '#back_to_score_btn'
      country_select: "#country"
      region_select: "#province"
      city_input: "#city"
      form: "#profile-form"

    regions:
      social: ".social-content"
      social_list: ".social-list"
      add_account: ".add-account"

    events:
      'click @ui.next': 'save'
      'click @ui.calendar_button' : 'showDateTimePicker'
      'change @ui.country_select' : 'checkCountry'


    templateHelpers:
      checked: (key, index, kol) ->
        v = kol[kol_fields_mapping[key]]
        return 'checked="checked"' if target[key][index] == v
        return 'checked="checked"' if key == 'genders' and "#{index}" == "#{v}"
        return ""

    initialize: (opts) ->
      @target = target
      @model = new Robin.Models.KolProfile App.currentKOL.attributes
      @model_binder = new Backbone.ModelBinder()
      @initial_attrs = @model.toJSON()
      @parent_view = opts.parent

    onRender: ->
      @model_binder.bind @model, @el
      $("#password").val("")
      $("#current_password").val("")
      $("#password_confirmation").val("")
      _.defer =>
        @initAddSocialAccount()
      @initSocialList()
      @initDatepicker()
      @$el.find('input[type=radio][checked]').prop('checked', 'checked')


       # I❤js
      _.defer =>
        crs.init()
      _.defer =>
        @checkCountry()
      _.defer =>
        @initFormValidation()

    initAddSocialAccount: ->
      @social_view = new Show.ProfileSocialView
        model: @model
        parent: this
      @showChildView 'add_account', @social_view

    initSocialList: (collection) ->
      socialList = new Robin.Collections.Identities(collection)
      @social_list_view = new Show.ProfileSocialListView
        collection: socialList
        parent: this
      if collection && collection.length > 0
        @showChildView 'social_list', @social_list_view
      else
        socialList.fetch
          success: (c, r, o) =>
            @showChildView 'social_list', @social_list_view

    refreshSocialList: (collection)->
      @initSocialList(collection)

    initDatepicker: ->
      chinaBirthdateOptions = {
        ignoreReadonly: true,
        format: 'YYYY-MM-DD',
        locale: 'zh-cn',
        maxDate: new Date()
      }
      usBirthdateOptions = {
        ignoreReadonly: true,
        format: 'MM/DD/YYYY',
        locale: 'en-gb',
        maxDate: new Date()
      }
      if Robin.chinaLocale
        @ui.datetimepicker.datetimepicker(chinaBirthdateOptions)
      else
        @ui.datetimepicker.datetimepicker(usBirthdateOptions)
      if @model.get('date_of_birthday')?
        @ui.datetimepicker.datetimepicker(new Date(@model.get('date_of_birthday')))

    initFormValidation: ->
      @ui.form.formValidation(
        framework: 'bootstrap'
        excluded: [
          ':hidden'
          ':disabled'
        ]
        icon:
          valid: 'glyphicon glyphicon-ok'
          invalid: 'glyphicon glyphicon-remove'
          validating: 'glyphicon glyphicon-refresh'
        fields:
          first_name:
            validators:
              notEmpty:
                message: polyglot.t('dashboard_kol.validation.first_name')
          last_name:
            validators:
              notEmpty:
                message: polyglot.t('dashboard_kol.validation.last_name')
          mobile_number:
            trigger: 'blur'
            validators:
              notEmpty:
                message: polyglot.t('dashboard_kol.validation.mobile')
              remote:
                message: 'phone number already exist'
                url: '/kols/valid_phone_number'
                data:
                  kol_id:  @model.id
                type: 'get'
#          date_of_birthday:
#            row: '.cell'
#            validators:
#              notEmpty:
#                message: ' '
          country:
            validators:
              notEmpty:
                message: polyglot.t('dashboard_kol.validation.country')
          province:
            validators:
              notEmpty:
                message: polyglot.t('dashboard_kol.validation.region')
          city:
            validators:
              notEmpty:
                message: polyglot.t('dashboard_kol.validation.city')
          current_password:
            enabled: false,
            validators:
              notEmpty:
                message: polyglot.t('profile.current_password_req')
              serverError:
                message: polyglot.t('profile.something_wrong')
          password:
            enabled: false,
            validators:
              notEmpty:
                message: polyglot.t('profile.password_required')
              serverError:
                message: polyglot.t('profile.something_wrong')
          password_confirmation:
            enabled: false,
            validators:
              notEmpty:
                message: polyglot.t('profile.password_confirmation_req')
              identical:
                field: 'password'
                message: polyglot.t('profile.password_confirmation_must_same')
              serverError:
                message: polyglot.t('profile.something_wrong')

      ).on('err.field.fv', (e, data) ->
          data.element.parents('.cell').addClass 'has-error'
      ).on('success.field.fv', (e, data) ->
          data.element.parents('.cell').removeClass 'has-error'
      ).on 'keyup', 'input[name="_password"]', ->
        isEmpty = $(@).val() == ''
        $('#profile-form').formValidation('enableFieldValidators', 'current_password', !isEmpty).formValidation('enableFieldValidators', '_password', !isEmpty).formValidation 'enableFieldValidators', 'password_confirmation', !isEmpty
        # Revalidate the field when user starts typing in the password field
        if $(@).val().length == 1
          $('#profile-form').formValidation('validateField', 'current_password').formValidation('validateField', '_password').formValidation 'validateField', 'password_confirmation'
      .on 'keyup', 'input[name="current_password"]', ->
        isEmpty = $(@).val() == ''
        $('#profile-form').formValidation('enableFieldValidators', 'current_password', !isEmpty).formValidation('enableFieldValidators', '_password', !isEmpty).formValidation 'enableFieldValidators', 'password_confirmation', !isEmpty
        # Revalidate the field when user starts typing in the password field
        if $(@).val().length == 1
          $('#profile-form').formValidation('validateField', 'current_password').formValidation('validateField', '_password').formValidation 'validateField', 'password_confirmation'
      .on 'keyup', 'input[name="password_confirmation"]', ->
        isEmpty = $(@).val() == ''
        $('#profile-form').formValidation('enableFieldValidators', 'current_password', !isEmpty).formValidation('enableFieldValidators', '_password', !isEmpty).formValidation 'enableFieldValidators', 'password_confirmation', !isEmpty
        # Revalidate the field when user starts typing in the password field
        if $(@).val().length == 1
          $('#profile-form').formValidation('validateField', 'current_password').formValidation('validateField', '_password').formValidation 'validateField', 'password_confirmation'
      .on 'blur', 'input[name="date_of_birthday"]', ->
        $('#profile-form').formValidation('revalidateField', 'date_of_birthday');

    showDateTimePicker: ->
      @ui.birthdate.click()

    checkCountry: ->
      if @ui.country_select.val() == ''
        @ui.region_select.attr('disabled', 'disabled')
        @ui.city_input.val ''
        @ui.city_input.attr('disabled', 'disabled')
      else
        @ui.region_select.removeAttr('disabled')
        @ui.city_input.removeAttr('disabled')

    serializeData: ->
      _.extend @target,
        k: @model.toJSON()

    validate: ->
      @ui.form.data('formValidation').validate()

    save: ->
      @validate()
      if @ui.form.data('formValidation').isValid()
        @model_binder.copyViewValuesToModel()
        @model.attributes.password = @model.attributes._password
        delete @model.attributes._password
        return if @model.toJSON() == @initial_attrs
        @model.save @model.attributes,
          success: (m, r) =>
            if m.attributes.first_name != @initial_attrs.first_name  || m.attributes.last_name != @initial_attrs.last_name
              Robin.vent.trigger("nameChanged", m.attributes.first_name + ' ' + m.attributes.last_name );
            @initial_attrs = m.toJSON()
            App.currentKOL.set m.attributes
            App.currentKOL.attributes.current_password = "";
            App.currentKOL.attributes.password = "";
            App.currentKOL.attributes.password_confirmation = "";
            $.growl "You profile was saved successfully", {type: "success"}
            $("#password").val("")
            $("#current_password").val("")
            $("#password_confirmation").val("")
            # @parent_view?.score()
            @parent_view?.defaultDashboard()
          error: (m, r) =>
            console.log "Error saving KOL profile. Response is:"
            console.log r
            if JSON.parse(r.responseText).error
              $.growl JSON.parse(r.responseText).error, {type: "error"}
            errors = JSON.parse(r.responseText).errors
            _.each errors, ((value, key) ->
              @ui.form.data('formValidation').updateStatus key, 'INVALID', 'serverError'
              val = value.join(',')
              if val == 'is invalid'
                val = polyglot.t('dashboard_kol.profile_tab.current_password_invalid')
              @ui.form.data('formValidation').updateMessage key, 'serverError', val

            ), this
            element = document.getElementById("current_password")
            element.scrollIntoView(false)
