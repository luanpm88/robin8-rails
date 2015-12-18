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
    mf: 'audience_gender_ratio'
    ages: 'audience_age_groups'
    regions: 'audience_regions'
    likes :'audience_likes'
    friends: 'audience_friends'
    groups: 'audience_talk_groups'
    publish: 'audience_publish_fres'


  Show.ProfileSocialModalAccount = Backbone.Marionette.ItemView.extend
    template: 'modules/dashboard-kol/templates/profile-social-modal-account'

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
                message: '请输入内容，否则请取消勾选'
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
          $.growl "您的个人资料已保存成功", {type: "success"}
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
