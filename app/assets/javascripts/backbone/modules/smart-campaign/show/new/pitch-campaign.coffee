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

      if @model.get('kols')
        @kols = @model.get('kols')
        kols = new Backbone.Collection(@model.get('kols'))
        if @model.get('kols').length > 0
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
      wechatTargetsView = new Show.WeChatTargets
        collection: wechat
      @showChildView 'wechatTargets', wechatTargetsView


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
      if form != undefined
        form.data('formValidation').validate()
        if form.data('formValidation').isValid()
          @model.save {},
            success: (m) ->
              location.href = '/#smart_campaign'
            error: (m) ->
              if @model.get('id')
                $.growl("Campaign can not be updated!", {type: "danger"})
              else
                $.growl("Campaign can not be created!", {type: "danger"})
