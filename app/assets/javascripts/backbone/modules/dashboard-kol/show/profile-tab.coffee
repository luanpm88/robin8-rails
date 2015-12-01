Robin.module 'DashboardKol.Show', (Show, App, Backbone, Marionette, $, _) ->
  flip = (f) -> (x, y) -> f y, x
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
    cn_industries:
      "50000000": "汽车"
      "51000000": "数码"
      "52000000": "教育"
      "53000000": "健康"
      "54000000": "体育"
      "55000000": "美妆"
      "56000000": "家具"
      "57000000": "旅游"
      "58000000": "美食"
      "59000000": "服饰"
      "60000000": "财经"
      "61000000": "音乐"
      "62000000": "军事"
      "63000000": "母婴"
      "64000000": "彩票"
      "65000000": "手机"
      "66000000": "计算机"
      "67000000": "数码相机"
      "68000000": "游戏"
      "69000000": "房地产"
      "70000000": "娱乐"
      "71000000": "卡通"
      "72000000": "宠物"
      "73000000": "家电"
      "74000000": "奢侈品"
      "75000000": "找工作"
      "76000000": "法律"
      "77000000": "其他"
    genders:
      0: 'secrecy'
      1: 'male'
      2: 'female'
    likes:
      0: '<5'
      1: '5-10'
      2: '11-20'
      3: '>20'
    friends:
      0: '<200'
      1: '201-500'
      2: '501-800'
      3: '>800'
    groups:
      0: '<3'
      1: '3-8'
      2: '9-12'
      3: '>12'
    publish:
      0: '<1'
      1: '1-2'
      2: '3-5'
      3: '>5'


  kol_fields_mapping =
    genders: 'gender'
    mf: 'audience_gender_ratio'
    ages: 'audience_age_groups'
    regions: 'audience_regions'
    likes :'audience_likes'
    friends: 'audience_friends'
    groups: 'audience_talk_groups'
    publish: 'audience_publish_fres'

  Show.ProfileTab = Backbone.Marionette.LayoutView.extend
    template: 'modules/dashboard-kol/show/templates/profile-tab'
    ui:
      birthdate:  "#birthdate"
      datetimepicker: "#datetimepicker"
      calendar_button: ".calendar_button"
      next: '#back_to_score_btn'
      test: '.test'
      industry: '#interests'
      country_select: "#country"
      region_select: "#province"
      city_input: "#city"
      form: "#profile-form"
      add_social: ".add-social"

    regions:
      social: ".social-content"
      social_list: ".social-list"
      add_account: ".add-account"

    events:
      'click @ui.next': 'save'
      'click @ui.calendar_button' : 'showDateTimePicker'
      'change @ui.country_select' : 'checkCountry'
      'click @ui.add_social'      : 'addSocial'


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
          date_of_birthday:
            row: '.cell'
            validators:
              notEmpty:
                message: ' '
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
      console.log @ui.country_select
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

    pickFields: ->
#      gender_ratio_i = _.find($("input[type=radio][name=mf]"), (el) -> el.checked).value.split('_')[1]
#      v = @target['mf'][gender_ratio_i]
#      @model.set kol_fields_mapping['mf'], v

    save: ->
      @validate()
      if @ui.form.data('formValidation').isValid()
        @pickFields()
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

  Show.ProfileSocialModalAccount = Backbone.Marionette.ItemView.extend
    template: 'modules/dashboard-kol/show/templates/profile-social-modal-account'

    templateHelpers:
      checked: (key, index, kol) ->
        v = kol[kol_fields_mapping[key]]
        return 'checked="checked"' if target[key][index] == v
        return 'checked="checked"' if key == 'genders' and "#{index}" == "#{v}"
        return ""
      active: (key, index, kol) ->
        return "" if !kol[kol_fields_mapping[key]]
        v = _.chain(kol[kol_fields_mapping[key]].split '|').map (x) ->
          x.trim()
        .compact().value()
        return "active" if target[key][index] in v
        return ""

    initialize: (opts) ->
      @target = target
      @industries = (if Robin.chinaInstance then  target["cn_industries"] else target["industries"])
      @model_attrs = @model.toJSON()
      @model_binder = new Backbone.ModelBinder()
      @parent_view = opts.parent

    ui:
      industry: '#interests'
      save_change: ".save_change"
      form: "#social-form"

    events:
      'click @ui.save_change': 'saveChange'

    onRender: ->
      @model_binder.bind @model, @el
      @.$el.find('input[type="checkbox"]').checkboxX({
        threeState: false, size:'md'
      })
      _.defer =>
        @initSelect2()
      @$el.find('input[type=radio][checked]').prop('checked', 'checked')
      @initPriceItemCheck()
      _.defer =>
        @initFormValidation()

    initPriceItemCheck: ->
      @.$el.find('.fixed-price input[type=text]').each ->
        if $(this).val()
          $(this).closest(".row").find('input[type=checkbox]').val("1")
          $(this).closest(".row").find('input[type=checkbox]').checkboxX('refresh')

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
        locale:  (if Robin.chinaLocale then 'zh_CN' else 'en_US')
        fields:
          item:
            selector: '.item'
            trigger: 'keyup'
            validators:
              callback:
                message: 'Please input value, or not check this item'
                callback: (value, validator, $field) ->
                  console.log  $field.closest(".row").find(".price-item").val()
                  console.log value
                  if $field.closest(".row").find(".price-item").val() == "1"  && value.length == 0
                    return false;
                  else
                    return true
              between:
                min: 0,
                max: 100000,
#          'price-item':
#            selector: '.price-item'
#            trigger: 'change'
#            validators:
#              message : ""
#              callback: (value, validator, $field) ->
#                console.log "change"
#                $("#social-form").formValidation('validateField', $field.closest(".row").find('.item'))
#                return true
      ).on('err.field.fv', (e, data) ->
        data.element.parents('.cell').addClass 'has-error'
      ).on('success.field.fv', (e, data) ->
        data.element.parents('.cell').removeClass 'has-error'
      ).on('change', '.price-item', (e) ->
        console.log("ccccchange")
        console.log $(this).closest(".row").find('.item')
        $('#social-form').formValidation('revalidateField', $(this).closest(".row").find('.item'));
      )

    saveChange: ->
      console.log "save change"
#      if @ui.form.data('formValidation').isValid()
      @pickFields()
      @model_binder.copyViewValuesToModel()
      return if @model.toJSON() == @initial_attrs
      @model.save @model.attributes,
        success: (m, r) =>
          @initial_attrs = m.toJSON()
          $.growl "You profile was saved successfully", {type: "success"}
          @parent_view.ui.modal_account.modal('hide')
          #TODO close modal (not refresh social-list beause not show any)
        error: (m, r) =>
          console.log "Error saving KOL profile. Response is:"
          console.log r
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


    pickFields: ->
      set_multi_value = (field) =>
        v = _.chain(@$el.find(".#{field}-row button.active")).map (el) ->
          el.name.split('_')[1]
        .map (x) ->
          console.log x
          target[field][x]
        .compact().value().join('|')
        @model.set kol_fields_mapping[field], v
      set_multi_value 'ages'
      set_multi_value 'regions'

      _target = @target
      _model = @model
      _(['mf','likes', 'friends', 'groups', 'publish']).map (item) ->
        item_checked = _.find($("input[type=radio][name=#{item}]"), (el) -> el.checked)
        if item_checked && item_checked.value
          item_ratio_i = item_checked.value.split('_')[1]
          v = _target[item][item_ratio_i]
          _model.set kol_fields_mapping[item], v

    initSelect2: ->
      _industries = @industries
      $('#interests').val("Industries")  # need to put something there for initSelection to be called
      @ui.industry.select2
        maximumSelectionSize: 5
        multiple: true
        minimumInputLength: 1
        width: '100%'
        placeholder: polyglot.t('dashboard_kol.profile_tab.industry_placeholder')
        ajax:
          url: '/kols/suggest_categories'
          dataType: 'json'
          quietMillis: 250,
          data: (term, page) ->
            return { f: term }
          results:  (data, page) ->
            return { results: data }
          cache:true
        escapeMarkup: _.identity
        initSelection: (el, callback) =>
          v = $("#interests").val()
          # 加载后初始化
          if v == "Industries"
            $("#interests").val('')
            $.get "/identities/#{@model.id}/current_categories", (data) ->
              callback data
          else        # 每次更改后初始化
            old_data = $("#interests").select2 'data'
            new_ids = _.compact v.split(',')
            new_data = _(new_ids).map (i) ->
              obj = _(old_data).find (x) -> x.id == i
              if typeof obj == "undefined"
                id: i
                text: _industries[i]
              else
                obj
            $("#interests").select2 'data', new_data

      @$el.find('.industry-row button').click (e) =>
        _.defer -> $(e.target).removeClass('active').blur()
        e.preventDefault()
        id = e.target.name.split('_')[1]
        old_val = _.compact @ui.industry.val().split(',')
        if old_val.length == 5
          $.growl polyglot.t('dashboard_kol.profile_tab.industry_placeholder') , {type: "danger"}
          return
        if not (id in old_val)
          old_val.push id
          $("#interests").val old_val
          $("#interests").trigger 'change'

    serializeData: ->
      _.extend @target,
        k: @model.toJSON()
        title: @options.title
        industries: @industries
