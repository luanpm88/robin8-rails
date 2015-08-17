Robin.module 'SmartCampaign.Show', (Show, App, Backbone, Marionette, $, _)->

  NoChildrenView = Marionette.ItemView.extend
    template: 'modules/smart-campaign/show/templates/pitch/pitch-weibo-empty-targets'

  Show.WeiboTargets = Backbone.Marionette.ItemView.extend
    template: 'modules/smart-campaign/show/templates/pitch/pitch-weibo-targets'
    emptyView: NoChildrenView

    ui:
      deleteButton: 'a.btn-danger'
      itemCount: '#item_count'

    events:
      'click @ui.deleteButton': 'deleteButtonClicked'

    deleteButtonClicked: (e) ->
      e.preventDefault()
      target = $ e.currentTarget
      weibo_id = target.data 'weibo-id'
      @count = @count - 1
      @ui.itemCount.text(@count)
      target.parents('tr').remove()
      this.triggerMethod('weibo:target:removed', weibo_id)

    onRender: ->
      @count = @collection.length


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
      this.ui.textarea.val(this.model.get('weibo_pitch'))
      this.ui.textareaPreview.val(this.model.get('weibo_pitch'))
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
        this.ui.textareaPreview.val(this.ui.textarea.val())
        this.model.set("weibo_pitch", this.ui.textarea.val())
