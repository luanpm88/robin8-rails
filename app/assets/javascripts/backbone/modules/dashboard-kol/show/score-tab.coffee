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


    save: ->
      @ui.form.data('formValidation').validate()
      if @ui.form.data('formValidation').isValid()
        @model_binder.copyViewValuesToModel()
        @model.save()
        window.debug_view = @

    next: ->
      @save()
      @options.parent.setState('campaigns')

    back: ->
      @save()
      @options.parent.setState('profile')

    initialize: (opts) ->
      @model = App.currentKOL
      @model_binder = new Backbone.ModelBinder()

    onRender: () ->
      @model_binder.bind @model, @el
      @$el.find('input[type=radio][checked]').prop('checked', 'checked')  # I❤js
      self = this
      @ui.form.validator()
      @ui.form.ready(self.init(self))

    init: (self) ->
      self.$(".graph-score").knob()
      self.initFormValidation()

      d = [
        [
          {axis:"Your influence channel",value:0.59},
          {axis:"Validity of social profile",value:0.56},
          {axis:"Weibo fans",value:0.42},
          {axis:"Content generation",value:0.34},
          {axis:"Social engagement",value:0.48},
        ]
      ]
      mycfg = {
        w: 500,
        h: 500,
        maxValue: 0.6,
        levels: 6,
        ExtraWidthX: 300
      }

      RadarChart.draw("#graph-score2", d, mycfg)


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
          monetize_create:
            validators:
              digits:
                message: ''
          share_price:
            validators:
              digits:
                message: ''
          review_price:
            validators:
              digits:
                message: ''
          review_price:
            validators:
              digits:
                message: ''


      ).on('err.field.fv', (e, data) ->
          data.element
            .data('fv.messages')
            .find('.help-block[data-fv-for="' + data.field + '"]').hide()
      )



