Robin.module 'SmartCampaign.Show', (Show, App, Backbone, Marionette, $, _)->

  Show.WeiboTargets = Backbone.Marionette.ItemView.extend
    template: 'modules/smart-campaign/show/templates/pitch/pitch-weibo-targets'

  Show.WeiboPitch = Backbone.Marionette.ItemView.extend
    template: 'modules/smart-campaign/show/templates/pitch/pitch-weibo'

    ui:
      textarea: '#weibo_pitch_textarea',
      textareaPreview: '#weibo_pitch_preview'
      form: '#weibo_pitch_form'

    events:
      'change @ui.textarea': 'weiboPitchTextChanged',
      'keyup @ui.textarea': 'weiboPitchTextChanged'

    onRender: (opts) ->
      this.ui.textarea.val(this.model.get('weibopitch'))
      this.ui.textareaPreview.val(this.model.get('weibopitch'))
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
          weibo_pitch_textarea: {
            trigger: 'blur'
            validators: {
              notEmpty: {
                message: 'The pitch text is required'
              }
            }
          }
        }
      })

    weiboPitchTextChanged: (e) ->
      @ui.form.data('formValidation').validate()
      if @ui.form.data('formValidation').isValid()
        this.model.set("weibopitch", this.ui.textarea.val())
