Robin.module 'SmartCampaign.Show', (Show, App, Backbone, Marionette, $, _)->

  Show.PitchCampaignDetails = Backbone.Marionette.ItemView.extend
    template: 'modules/smart-campaign/show/templates/pitch/pitch-campaign-details'
    className: 'panel panel-primary'

    ui:
      form: '#details_form'
      invite_kol: "input[id=\'icheckbox_flat\']"
      budget: "input[name=budget]"

    events:
      'ifChecked @ui.invite_kol': 'setNonCashBudget'
      'ifUnchecked @ui.invite_kol': 'setCashBudget'

    initialize: (options) ->
      @options = options
      @model = if @options.model? then @options.model else new Robin.Models.Campaign()
      @modelBinder = new Backbone.ModelBinder()

    onRender: () ->
      self = this
      @ui.form.ready(self.initFormValidation())
      @$el.find('input[id=\'icheckbox_flat\']').iCheck
        checkboxClass: 'icheckbox_square-blue'
        increaseArea: '20%'
      @modelBinder.bind(@model, @el)
      monthes = []
      monthesShort = []
      daysMin = []
      days = []
      for i in [0..11]
        monthes[i] = polyglot.t('date.monthes_full.m' + (i + 1))
        monthesShort[i] = polyglot.t('date.monthes_abbr.m' + (i + 1))
      for i in [0..6]
        days[i] = polyglot.t('date.days_full.d' + (i + 1))
        daysMin[i] = polyglot.t('date.datepicker_days.d' + (i + 1))
      @$el.find("#deadline").datepicker
        monthNames: monthes
        monthNamesShort: monthesShort
        dayNames: days
        dayNamesMin: daysMin
        nextText: polyglot.t('date.datepicker_next')
        prevText: polyglot.t('date.datepicker_prev')
        dateFormat: "D, d M y"
      if @model.get('deadline')?
        @$el.find("#deadline").datepicker("setDate", new Date(@model.get('deadline')))
      if @model.get('non_cash')?
        if @model.get('non_cash') == true
          @ui.invite_kol.iCheck('check');
      if @model.get('content_type')?
        @$el.find("#content_type").value = @model.get('content_type')

    setNonCashBudget: (e) ->
      @ui.budget.val(0);
      @model.set('non_cash', true)
    setCashBudget: (e) ->
      @model.set('non_cash', false)


    initFormValidation: () ->
      @ui.form.formValidation({
        framework: 'bootstrap',
        icon: {
          valid: 'glyphicon glyphicon-ok',
          invalid: 'glyphicon glyphicon-remove',
          validating: 'glyphicon glyphicon-refresh'
        },
        excluded: ':disabled',
        fields: {
          budget: {
            trigger: 'blur'
            validators: {
              notEmpty: {
                message: polyglot.t('smart_campaign.pitch_step.subject_required')
              }
            }
          },
          deadline: {
            trigger: 'blur'
            validators: {
              notEmpty: {
                message: polyglot.t('smart_campaign.pitch_step.email_required')
              }
            }
          },
          short_description: {
            trigger: 'change'
            validators: {
              notEmpty: {
                message: polyglot.t('smart_campaign.pitch_step.emailtext_required')
              }
            }
          }
        }
      })
