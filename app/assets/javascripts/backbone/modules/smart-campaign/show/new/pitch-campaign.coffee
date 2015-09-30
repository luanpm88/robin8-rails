Robin.module 'SmartCampaign.Show', (Show, App, Backbone, Marionette, $, _)->

  Show.PitchTab = Backbone.Marionette.LayoutView.extend
    template: 'modules/smart-campaign/show/templates/pitch-tab'

    regions:
      emailPitch: '#email-pitch',
      emailTargets: '#email-targets',
      wechatPitch:  '#wechat-pitch',
      wechatTargets: '#wechat-targets',
      weiboPitch: '#weibo-pitch',
      weiboTargets: '#weibo-targets'
      campaignDetails: '#campaign-details'

    ui:
      pitchButton: "#save-pitch"

    events:
      "click @ui.pitchButton": "pitchButtonClicked"

    childEvents:
      'email:target:removed': (childView, id) ->
        kol = _(@kols).find (k) -> k.id == id
        index = _.indexOf(@kols, kol)
        @kols.splice(index, 1)
        @model.set('kols', @kols)
        if @kols.length == 0
          this.renderTab()

      'email_list_item:target:removed': (childView, id) ->
        kol = _(@kols_list).find (k) -> k.id == id
        index = _.indexOf(@kols_list, kol)
        @kols_list.splice(index, 1)
        @model.set('kols_list', @kols_list)
        if @kols_list.length == 0
          this.renderTab()

      'weibo:target:removed': (childView, id) ->
        weibo = _(@weibo).find (k) -> k.id == id
        index = _.indexOf(@weibo, weibo)
        @weibo.splice(index, 1)
        @model.set('weibo', @weibo)
        if @weibo.length == 0
          this.renderTab()

    onRender: (opts) ->
      this.renderTab()


    renderTab: () ->

      @model.set('email_pitch' , polyglot.t("smart_campaign.pitch_step.email_panel.email_pitch"))
      @model.set('weibo_pitch' , polyglot.t("smart_campaign.pitch_step.weibo_panel.weibo_pitch"))
      @model.set('wechat_pitch' , polyglot.t("smart_campaign.pitch_step.weibo_panel.weibo_pitch"))

      if @model.get('kols') or @model.get('kols_list_contacts')
        @kols = if @model.get('kols') then @model.get('kols') else []
        @kols_list = if @model.get('kols_list_contacts') then @model.get('kols_list_contacts') else []

        if @kols.length > 0 or @kols_list.length > 0
          all_kols = {}
          if @kols.length > 0
            all_kols['kols'] = @kols
          if @kols_list.length > 0
            all_kols['kols_list'] = @kols_list
          kols = new Backbone.Collection(all_kols)
          @emailTargetsView = new Show.EmailTargets
            collection: kols
          @showChildView 'emailTargets', @emailTargetsView
          @emailView = new Show.EmailPitch
            model: @model
          @showChildView 'emailPitch', @emailView
        else
          kols = new Backbone.Collection()
          @emailTargetsView = new Show.EmailTargets
            collection: kols
          @showChildView 'emailTargets', @emailTargetsView
      else
        kols = new Backbone.Collection()
        @emailTargetsView = new Show.EmailTargets
          collection: kols
        @showChildView 'emailTargets', @emailTargetsView

      if @model.get('weibo')
        @weibo = @model.get('weibo')
        weibo = new Backbone.Collection(@model.get('weibo'))
        if @model.get('weibo').length > 0
          @weiboTargetsView = new Show.WeiboTargets
            collection: weibo
          @showChildView 'weiboTargets', @weiboTargetsView
          @weiboView = new Show.WeiboPitch
            model: @model
          @showChildView 'weiboPitch', @weiboView
        else
          weibo = new Backbone.Collection()
          @weiboTargetsView = new Show.WeiboTargets
            collection: weibo
          @showChildView 'weiboTargets', @weiboTargetsView
      else
        weibo = new Backbone.Collection()
        @weiboTargetsView = new Show.WeiboTargets
          collection: weibo
        @showChildView 'weiboTargets', @weiboTargetsView


      wechat = new Backbone.Collection()
      @wechatTargetsView = new Show.WeChatTargets
        collection: wechat
      @showChildView 'wechatTargets', @wechatTargetsView
      @wechatView = new Show.WeChatPitch
        model: @model
      @showChildView 'wechatPitch', @wechatView

      @campaignDetails = new Show.PitchCampaignDetails
        model: @model
      @showChildView 'campaignDetails', @campaignDetails


      #if wechat.length > 0
      #  wechatTargetsView = new Show.WeChatTargets
      #    model: @model
      #  @showChildView 'wechatTargets', wechatTargetsView
      #  wechatView = new Show.WeChatPitch
      #    model: @model
      #  @showChildView 'wechatPitch', wechatView


    pitchButtonClicked: (e) ->
      e.preventDefault()
      form = @emailView.$el.find('#email_pitch_form')
      details_form = @campaignDetails.$el.find('#details_form')
      if form != undefined and details_form != undefined
        form.data('formValidation').validate()
        details_form.data('formValidation').validate()
        if form.data('formValidation').isValid() && details_form.data('formValidation').isValid()
          @model.set('budget', @campaignDetails.$el.find('#budget').val())
          @model.set('content_type', @campaignDetails.$el.find('#content_type').val())
          @model.save {},
            success: (m) ->
              if m.attributes.created_at != null and m.attributes.created_at != undefined
                $.growl(polyglot.t('smart_campaign.pitch_step.updated_success'), {type: "success"})
              else
                $.growl(polyglot.t('smart_campaign.pitch_step.created_success'), {type: "success"})
              location.href = '/#smart_campaign'
            error: (m) ->
              if @model.get('id')
                $.growl("Campaign can not be updated!", {type: "danger"})
              else
                $.growl("Campaign can not be created!", {type: "danger"})

