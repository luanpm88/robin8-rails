Robin.module 'SmartCampaign.Show', (Show, App, Backbone, Marionette, $, _)->
  NoChildrenView = Marionette.ItemView.extend
    template: 'modules/smart-campaign/show/templates/pitch/pitch-wechat-empty-targets'

  Show.WeChatTargets = Backbone.Marionette.ItemView.extend
    template: 'modules/smart-campaign/show/templates/pitch/pitch-wechat-targets'
    emptyView: NoChildrenView

  Show.WeChatPitch = Backbone.Marionette.ItemView.extend
    template: 'modules/smart-campaign/show/templates/pitch/pitch-wechat'
    className: 'panel panel-primary'

    ui:
      textarea: '#wechat_pitch_textarea',
      textareaPreview: '#wechat_pitch_preview'
      form: '#wechat_pitch_form'

    events:
      'change @ui.textarea': 'wechatPitchTextChanged',
      'keyup @ui.textarea': 'wechatPitchTextChanged'

    onRender: (opts) ->
      this.ui.textarea.val(this.model.get('wechat_pitch'))
      this.ui.textareaPreview.val(this.model.get('wechat_pitch'))
      that = this;
      @ui.form.ready(that.initFormValidation())


    initFormValidation: () ->
      @ui.form.formValidation({
        framework: 'bootstrap',
        excluded: [':disabled', ':hidden'],
        icon: {
          valid: 'glyphicon glyphicon-ok',
          invalid: 'glyphicon glyphicon-remove',
          validating: 'glyphicon glyphicon-refresh'
        },
        fields: {
          wechat_pitch_textarea: {
            trigger: 'blur'
            validators: {
              notEmpty: {
                message: 'The pitch text is required'
              }
            }
          }
        }
      })

    wechatPitchTextChanged: (e) ->
      @ui.form.data('formValidation').validate()
      if @ui.form.data('formValidation').isValid()
        this.ui.textareaPreview.val(this.ui.textarea.val())
        this.model.set("wechat_pitch", this.ui.textarea.val())
