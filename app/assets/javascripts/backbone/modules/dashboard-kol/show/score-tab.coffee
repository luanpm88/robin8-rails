Robin.module 'DashboardKol.Show', (Show, App, Backbone, Marionette, $, _)->

  Show.ScoreTab = Backbone.Marionette.LayoutView.extend
    template: 'modules/dashboard-kol/show/templates/score-tab'
    ui:
      form: '#score_form'
      next: '#next_to_campaign_btn'
      back: '#back_to_profile_btn'

    events:
      'click @ui.next': 'next'
      'click @ui.back': 'back'

    templateHelpers: () ->
      vs: () ->
        polyglot.t('dashboard_kol.score_tab.vsmonth', {per: "+25%" })
      beat: () ->
        polyglot.t('dashboard_kol.score_tab.youbeat', {per: "50%" })
      score: () ->
        "75"


    save: ->
      @ui.form.data('formValidation').validate()
      if @ui.form.data('formValidation').isValid()
        @ui.form.data('formValidation').resetForm()
        @model_binder.copyViewValuesToModel()
        return if @model.toJSON() == @initial_attrs
        @model.monetize @model.attributes,
          success: (m, r) =>
            @initial_attrs = m.toJSON()
            $.growl "You profile was saved successfully", {type: "success"}
          error: (m, r) =>
            console.log "Error saving KOL profile. Response is:"
            console.log r
            $.growl "Can't save profile info", {type: "danger"}

    next: ->
      @save()
      @parent_view?.campaigns()


    back: ->
      @save()
      @parent_view?.profile()

    initialize: (opts) ->
      @model = new Robin.Models.KolProfile App.currentKOL.attributes
      @initial_attrs = @model.toJSON()
      @model_binder = new Backbone.ModelBinder()
      @parent_view = opts.parent

    onRender: () ->
      @model_binder.bind @model, @el
      @$el.find('input[type=radio][checked]').prop('checked', 'checked')  # I❤js
      self = this
      @ui.form.validator()
      @ui.form.ready(self.init(self))

    init: (self) ->
      self.initFormValidation()

      self.$(".graph-score").knob()

      d = [
        [
          {axis:"Your influence channel",value:50},
          {axis:"Validity of social profile",value:60},
          {axis:"Weibo fans",value:42},
          {axis:"Content generation",value:34},
          {axis:"Social engagement",value:48},
        ]
      ]
      mycfg = {
        w: 285,
        h: 150,
        maxValue: 100,
        levels: 1,
        ExtraWidthX: 155
      }


      el = self.$('#graph_score2')

      RadarChart.draw(el[0], d, mycfg)

      #this.widget.validators.push(this.maxFileSize(3145728))

    onShow: () ->
      if @model.attributes.avatar_url
        $("#avatar-image").attr('src', @model.attributes.avatar_url)

      viewObj = this;
      this.widget = uploadcare.Widget('[role=uploadcare-uploader]').onUploadComplete( (info) ->
        console.log(info.cdnUrl)
        $("#avatar-image").attr('src', info.cdnUrl)
        viewObj.model.set({avatar_url: info.cdnUrl})
      )

    initFormValidation: () ->
      @ui.form.formValidation(
        framework: 'bootstrap'
        icon:
          valid: 'glyphicon glyphicon-ok',
          invalid: 'glyphicon glyphicon-remove',
          validating: 'glyphicon glyphicon-refresh'
        fields:
          monetize_post:
            validators:
              digits:
                message: ''
          monetize_post_weibo:
            validators:
              digits:
                message: ''
          monetize_post_personal:
            validators:
              digits:
                message: ''
          monetize_post_public1st:
            validators:
              digits:
                message: ''
          monetize_post_public2nd:
            validators:
              digits:
                message: ''
          monetize_create:
            validators:
              digits:
                message: ''
          monetize_create_weibo:
            validators:
              digits:
                message: ''
          monetize_create_personal:
            validators:
              digits:
                message: ''
          monetize_create_public1st:
            validators:
              digits:
                message: ''
          monetize_create_public2nd:
            validators:
              digits:
                message: ''
          monetize_share:
            validators:
              digits:
                message: ''
          monetize_share_weibo:
            validators:
              digits:
                message: ''
          monetize_share_personal:
            validators:
              digits:
                message: ''
          monetize_share_public1st:
            validators:
              digits:
                message: ''
          monetize_share_public2nd:
            validators:
              digits:
                message: ''
          monetize_review:
            validators:
              digits:
                message: ''
          monetize_review_weibo:
            validators:
              digits:
                message: ''
          monetize_review_personal:
            validators:
              digits:
                message: ''
          monetize_review_public1st:
            validators:
              digits:
                message: ''
          monetize_review_public2nd:
            validators:
              digits:
                message: ''
          monetize_speech:
            validators:
              digits:
                message: ''
          monetize_speech_weibo:
            validators:
              digits:
                message: ''
          monetize_speech_personal:
            validators:
              digits:
                message: ''
          monetize_speech_public1st:
            validators:
              digits:
                message: ''
          monetize_speech_public2nd:
            validators:
              digits:
                message: ''
          monetize_event:
            validators:
              digits:
                message: ''
          monetize_focus:
            validators:
              digits:
                message: ''
          monetize_party:
            validators:
              digits:
                message: ''
          monetize_endorsements:
            validators:
              digits:
                message: ''
      ).on('err.field.fv', (e, data) ->
        data.element
        .data('fv.messages')
        .find('.help-block[data-fv-for="' + data.field + '"]').hide()
      )



