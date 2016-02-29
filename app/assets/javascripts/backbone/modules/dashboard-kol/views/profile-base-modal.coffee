Robin.module 'DashboardKol.Show', (Show, App, Backbone, Marionette, $, _) ->
  target =
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

  Show.ProfileBaseModal = Backbone.Marionette.LayoutView.extend
    template: 'modules/dashboard-kol/templates/profile-base-modal'
    ui:
      next: '#back_to_score_btn'
      form: "#profile-form"
      verify_code_button: ".send_sms"
      kol_interests: "#kol_interests"

    events:
      'click .save-base': 'save'
      'click @ui.verify_code_button' : 'send_sms'

    initialize: (opts) ->
      @target = target
      @industries = @target["cn_industries"]
      @model = new Robin.Models.KolProfile App.currentKOL.attributes
      @attrs = @model.attributes


    onRender: ->
      console.log "ProfileBaseModal"
      _.defer =>
        if @attrs.category_size == 0
          @initKolSelect2()

    initKolSelect2: ->
      console.log "initKolSelect2"
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


    serializeData: ->
      _.extend @target,
        k: @model.toJSON()
        industries: @industries


    save: ->
      parentThis = this
      if @attrs.category_size == 0
        if $("#kol_interests").val() == 'Interests' ||   $("#kol_interests").val() == ''
          $('.select2-container .select2-choices').css 'border-color': 'red'
          $('.not_unique_number').show()
          $('.not_unique_number').siblings().hide()
        else
          parentThis.model.attributes.interests = $("#kol_interests").val()
      if !@attrs.mobile_number
        phone_number = $('#mobile').val().trim()
        verify_code = $('.verify-code').val().trim()
        if phone_number && verify_code
          parentThis.model.attributes.mobile_number = phone_number
          parentThis.submit_kol()
        else if phone_number
          $.growl "请输入手机验证码", {type: "danger"}
        else
          $.growl "手机号码不能为空", {type: "danger"}
      else
        parentThis.submit_kol()

    submit_kol: ()->
      console.log "submit_kol"
      @model.save @model.attributes,
        success: (m, r) =>
          window.location.href= '/'
          $.growl(polyglot.t('dashboard_kol.profile_tab.save_success'), {type: "success"})

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
          data: {'phone_number': phone_number, "login_user": "yes"}
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
