Robin.module 'DashboardKol.Show', (Show, App, Backbone, Marionette, $, _)->

  Show.ScoreTab = Backbone.Marionette.LayoutView.extend
    template: 'modules/dashboard-kol/show/templates/score-tab'
    ui:
      form: '#score_form'
      next: '#next_to_campaign_btn'
      back: '#back_to_profile_btn'
      check_all: '#monetize_interested_all'


    events:
      'click @ui.next': 'next'
      'click @ui.back': 'back'
      'change @ui.check_all': 'check_all'


    serializeData: () ->
      k: @model.toJSON()


    templateHelpers: () ->
      vs: (k) ->
        if k.stats.total_progress > 0
          polyglot.t('dashboard_kol.score_tab.vsmonth', {per: "+#{k.stats.total_progress}%" })
        else
          polyglot.t('dashboard_kol.score_tab.vsmonth', {per: "#{k.stats.total_progress}%" })
      beat: (k) ->
        polyglot.t('dashboard_kol.score_tab.youbeat', {per: "#{k.stats.total_beat}%" })
      score: (k) ->
        k.stats.total

    save: (cb) ->
      @ui.form.data('formValidation').validate()
      if @ui.form.data('formValidation').isValid()
        @model_binder.copyViewValuesToModel()
        return if @model.toJSON() == @initial_attrs
        @model.monetize @model.attributes,
          success: (m, r) =>
            @initial_attrs = m.toJSON()
            App.currentKOL.set m.attributes
            $.growl "You value was saved successfully", {type: "success"}
            cb()
          error: (m, r) =>
            console.log "Error saving KOL profile. Response is:"
            console.log r
            $.growl "Can't save value info", {type: "danger"}

    next: ->
      @save =>
        @parent_view?.campaigns()

    back: ->
      @save =>
        @parent_view?.profile()

    initialize: (opts) ->
      @model = new Robin.Models.KolProfile App.currentKOL.attributes
      @initial_attrs = @model.toJSON()
      @model_binder = new Backbone.ModelBinder()
      @parent_view = opts.parent

    onRender: () ->
      @model_binder.bind @model, @el
      @$el.find('input[type=checkbox][checked]').prop('checked', 'checked')  # I❤js
      self = this
      @ui.form.validator()
      @ui.form.ready(self.init(self))


    init: (self) ->
      self.initFormValidation()

      if self.$("input:checkbox:checked").length == 9
        self.$el.find('#monetize_interested_all').prop('checked', 'checked')

      @.$el.find("input:checkbox:checked").prop('value', '1')

      @.$('input[type="checkbox"]').checkboxX({threeState: false, size:'lg'})

    onShow: () ->
      if @model.attributes.avatar_url
        $("#avatar-image").attr('src', @model.attributes.avatar_url)

      viewObj = this
      this.widget = uploadcare.Widget('[role=uploadcare-uploader]').onUploadComplete( (info) ->
        $("#avatar-image").attr('src', info.cdnUrl)
        viewObj.model.set({avatar_url: info.cdnUrl})
      )

    check_all: () ->
      if @ui.check_all.is(':checked')
        @$el.find('input[type=checkbox]').prop('checked', 'checked')
        @.$el.find("input:checkbox").prop('value', '1')
      else
        @$el.find('input[type=checkbox]').prop('checked', '')
        @.$el.find("input:checkbox").prop('value', '0')

      #@.$("input:checkbox").checkboxX({threeState: false, size:'lg'})
      @.$el.find("input:checkbox").checkboxX('refresh');

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



