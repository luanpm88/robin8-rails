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
        this.renderTab()

    onRender: (opts) ->
      this.renderTab()


    renderTab: () ->
      @model.set('email_pitch' , polyglot.t("smart_campaign.pitch_step.email_panel.email_pitch"))

      if @model.get('kols')
        @kols = @model.get('kols')
        kols = new Backbone.Collection(@model.get('kols'))

        if @model.get('kols').length > 0
          emailTargetsView = new Show.EmailTargets
            collection: kols
          @showChildView 'emailTargets', emailTargetsView
          emailView = new Show.EmailPitch
            model: @model
          @showChildView 'emailPitch', emailView
        else
          @options.parent.setState('target')
      else
        @options.parent.setState('target')

      #if wechat.length > 0
      #  wechatTargetsView = new Show.WeChatTargets
      #    model: @model
      #  @showChildView 'wechatTargets', wechatTargetsView
      #  wechatView = new Show.WeChatPitch
      #    model: @model
      #  @showChildView 'wechatPitch', wechatView

      #if weibo.length > 0
      #  weiboTargetsView = new Show.WeiboTargets
      #    model: @model
      #  @showChildView 'weiboTargets', weiboTargetsView
      #  weiboView = new Show.WeiboPitch
      #    model: @model
      #  @showChildView 'weiboPitch', weiboView

    pitchButtonClicked: (e) ->
      e.preventDefault()

      @model.save {},
        success: (m) ->
          $.growl message: "Saved!"
          location.href = '/#smart_campaign'
        error: (m) ->
          location.href = '/#smart_campaign'
          
      location.href = '/#smart_campaign'













