Robin.module 'DashboardKol.Show', (Show, App, Backbone, Marionette, $, _) ->
  target =
    genders:
      0: 'secrecy'
      1: 'male'
      2: 'female'
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
      verify_code_button: ".send_sms"
      kol_interests: "#kol_interests"
      test: "#test"

    regions:

      social: ".social-content"
      social_list: ".social-list"
      add_account: ".add-account"
      test_modal: "#test-modal"


    events:
      'click @ui.next': 'save'
      'click @ui.calendar_button' : 'showDateTimePicker'
      'change @ui.country_select' : 'checkCountry'
      'click @ui.verify_code_button' : 'send_sms'
      'click @ui.test': 'test'

    test: ()->
      @base_modal = new Show.ProfileBaseModal
        model: @model
        parent: this
      @showChildView 'test_modal', @base_modal

    templateHelpers:
      checked: (key, index, kol) ->
        v = kol[kol_fields_mapping[key]]
        return 'checked="checked"' if target[key][index] == v
        return 'checked="checked"' if key == 'genders' and "#{index}" == "#{v}"
        return ""

    initialize: (opts) ->
      @target = target
      @industries = @target["cn_industries"]
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
        @initKolSelect2()
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

    onShow: ->
      if Robin.currentKOL.attributes.mobile_number != null
        $("input#mobile").focus()
        a = 1
        $(window).scroll ->
          if a == 1
            a++
            $("input#mobile").blur()
          return

    initKolSelect2: ->
      _industries = @industries
      $('#kol_interests').val("Industries")  # need to put something there for initSelection to be called
      @ui.kol_interests.select2
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
          v = $("#kol_interests").val()
          # 加载后初始化
          if v == "Industries"
            $("#kol_interests").val('')
            $.get "/kols/current_categories", (data) ->
              callback data
          else        # 每次更改后初始化
            old_data = $("#kol_interests").select2 'data'
            console.log old_data
            console.log v
            new_ids = _.compact v.split(',')
            new_data = _(new_ids).map (i) ->
              obj = _(old_data).find (x) -> x.id == i
              if typeof obj == "undefined"
                id: i
                text: _industries[i]
              else
                obj
            $("#kol_interests").select2 'data', new_data

      @$el.find('.industry-row button').click (e) =>
        _.defer -> $(e.target).removeClass('active').blur()
        e.preventDefault()
        id = e.target.name.split('_')[1]
        old_val = _.compact @ui.kol_interests.val().split(',')
        if old_val.length == 5
          $.growl polyglot.t('dashboard_kol.profile_tab.industry_placeholder') , {type: "danger"}
          return
        if not (id in old_val)
          old_val.push id
          $("#kol_interests").val old_val
          $("#kol_interests").trigger 'change'

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
            trigger: 'blur'
            validators:
              notEmpty:
                message: polyglot.t('dashboard_kol.validation.first_name')
          last_name:
            trigger: 'blur'
            validators:
              notEmpty:
                message: polyglot.t('dashboard_kol.validation.last_name')
          # mobile_number:
          #   trigger: 'blur'
          #   validators:
          #     notEmpty:
          #       message: polyglot.t('dashboard_kol.validation.mobile')
          #     callback:
          #       message: polyglot.t('kols.mobile_format_error')
          #       callback: (value, validator, $field) ->
          #         RegExp = /^1[34578][0-9]{9}$/;
          #         if RegExp.test(value)
          #           return true
          #         return false
          #     remote:
          #       message: 'phone number already exist'
          #       type: 'get'
          #       url: '/kols/valid_phone_number'
          #       data:
          #         kol_id:  @model.id
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
        industries: @industries

    validate: ->
      @ui.form.data('formValidation').validate()

    save: ->
      parentThis = this
      @validate()
      if @ui.form.data('formValidation').isValid()

        phone_number = $('#mobile').val().trim()
        verify_code = $('.verify-code').val().trim()

        if phone_number && verify_code
          $.ajax(
            method: 'POST'
            url: '/kols/valid_verify_code'
            beforeSend: (xhr) ->
              xhr.setRequestHeader 'X-CSRF-Token', $('meta[name="csrf-token"]').attr('content')
              return
            data: 'phone_number': phone_number,'verify_code': verify_code).done (data) ->
              if data['valid']
                parentThis.save_kol()
              else
                $.growl "手机号码和验证码不匹配，请重新输入", {type: "danger"}
        else if phone_number
          if @initial_attrs.mobile_number != phone_number
            $.growl "请输入手机验证码", {type: "danger"}
          else
            this.save_kol()
        else
          if phone_number
            this.save_kol()
          else
            $.growl "手机号码不能为空", {type: "danger"}

    save_kol: ->
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
          $.growl(polyglot.t('dashboard_kol.profile_tab.save_success'), {type: "success"})
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

    send_sms: ->
      phone_number = $('#mobile').val().trim()
      old_button_text = $('.send_sms').text()
      count = 60
      countdown = undefined

      CountDown = ->
        $('.send_sms').attr 'disabled', 'true'
        $('.send_sms').text count + ' s'
        if count == 0
          $('.send_sms').text(old_button_text).removeAttr 'disabled'
          clearInterval countdown
        count--
        return

      if phone_number.match(/^1[34578][0-9]{9}$/) or phone_number == 'robin8.best'
        $.ajax(
          method: 'POST'
          url: '/kols/send_sms'
          beforeSend: (xhr) ->
            xhr.setRequestHeader 'X-CSRF-Token', $('meta[name="csrf-token"]').attr('content')
            return
          data: 'phone_number': phone_number
        ).done (data) ->
          $('.tips').children().hide()
          if data['mobile_number_is_blank']
            $('#mobile').focus().blur()
            return null
          if data['not_unique']
            $('#mobile').css 'border-color': 'red'
            $('.not_unique_number').show()
            $('.not_unique_number').siblings().hide()
          else
            if data['code']
              $('#mobile').css 'border-color': 'red'
              $('.send_sms_failed').show()
              $('.send_sms_failed').siblings().hide()
            else
              countdown = setInterval(CountDown, 1000)
              $('.send_sms_success').show()
              $('.send_sms_success').siblings().hide()
          return
      else
        $('#mobile').focus().blur()
