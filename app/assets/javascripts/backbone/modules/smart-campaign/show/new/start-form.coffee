Robin.module 'SmartCampaign.Show', (Show, App, Backbone, Marionette, $, _)->

  Show.StartTab = Backbone.Marionette.LayoutView.extend
    template: 'modules/smart-campaign/show/templates/start-tab'

    regions:
      content: "#campaign-content"
      analyticsRegion: '#analytics-campaign-text'

    ui:
      startDatePicker: "#datetimepicker6"
      endDatePicker: "#datetimepicker7"
      createCampagin: "#create-campagin"
      form: "#campaign-form"
      subtractionBudgetIcon: ".subtraction_budget_icon"
      plusBudgetIcon: ".plus_budget_icon"
      subtractionPerBudgetIcon: ".subtraction_per_budget_icon"
      plusPerBudgetIcon: ".plus_per_budget_icon"
      deadlineIcon: ".deadline_icon"

    events:
      "click @ui.createCampagin": "createCampagin"
      "click @ui.subtractionBudgetIcon": "subtractionBudgetIcon"
      "click @ui.plusBudgetIcon": "plusBudgetIcon"
      "click @ui.subtractionPerBudgetIcon": "subtractionPerBudgetIcon"
      "click @ui.plusPerBudgetIcon": "plusPerBudgetIcon"
      "click @ui.deadlineIcon": "deadlineIcon"

    initialize: (options) ->
      @options = options
      @model = if @options.model? then @options.model else new Robin.Models.Campaign()
      @modelBinder = new Backbone.ModelBinder()

    onRender: () ->
      @modelBinder.bind @model, @el
      @initDatepicker()
      _.defer =>
        @initFormValidation()

    initFormValidation: ->
      @ui.form.formValidation(
        framework: 'bootstrap'
        excluded: [
          ':hidden'
          ':disabled'
        ]
        icon:
          valid: 'glyphicon glyphicon-ok'
          #invalid: 'glyphicon glyphicon-remove'
          validating: 'glyphicon glyphicon-refresh'
        fields:
          name:
            validators:
              notEmpty:
                message: polyglot.t('smart_campaign.validation.name')
          description:
            validators:
              notEmpty:
                message: polyglot.t('smart_campaign.validation.description')
          url:
            validators:
              notEmpty:
                message: polyglot.t('smart_campaign.validation.url')
              callback:
                message: polyglot.t('smart_campaign.validation.url_invalid')
                callback: (value, validator, $field) ->
                  RegExp = /^(http|https):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/;
                  if RegExp.test(value)
                    return true
                  return false
          budget:
            validators:
              notEmpty:
                message: polyglot.t('smart_campaign.validation.budget')
              integer:
                message: polyglot.t('smart_campaign.validation.budget_should_be_digit')
              greaterThan:
                value: 0
                message:  polyglot.t('smart_campaign.validation.budget_should_greater_than_zero')
              remote:
                url: "/users/avail_amount"
                type: "get"
                delay: 300
                message: polyglot.t('smart_campaign.validation.budget_is_not_ample')
                data: (value, validators, $field) ->
                  v = 
                    amount: $('.budget_input').val()
                  return v

              # callback:
              #   callback: (value, validators, $field) ->
              #     $.ajax 
              #       url: "/users/avail_amount"
              #       success: (data) ->
              #         if Number(data["data"]) > Number(value)
              #           return true
              #         return false
              #       error: ->
              #         return false
          per_click_budget:
            validators:
              notEmpty:
                message: polyglot.t('smart_campaign.validation.per_click_budget')
              numeric:
                message: polyglot.t('smart_campaign.validation.per_click_budget_should_be_digit')
              greaterThan:
                value: 0
                message:  polyglot.t('smart_campaign.validation.per_click_budget_should_greater_than_zero')
              callback: 
                message: polyglot.t('smart_campaign.validation.per_click_budget_should_less_than_budget')
                callback: (value, validator, $field) ->
                  if Number(value) > Number($(".budget_input").val())
                    return false
                  return true
          deadline:
            validators:
              callback: 
                selector: ".test"
                message: polyglot.t('smart_campaign.validation.campaign_end_time_should_greather_than_start_time')
                callback: (value, validator, $field) ->
                  if (new Date($(".campaign_start_time_input").val()).getTime()) > (new Date($(".campaign_deadline_input").val()).getTime()) 
                    return false
                  return true

        )

    initDatepicker: ->
      chinaDateOptions = {
        ignoreReadonly: true,
        format: 'YYYY-MM-DD HH:mm',
        locale: 'zh-cn',
        defaultDate: new Date()
      }
      usDateOptions = {
        ignoreReadonly: true,
        format: 'YYYY-MM-DD HH:mm',
        locale: 'en-gb',
        minDate: new Date()
      }
      if Robin.chinaLocale
        @ui.startDatePicker.datetimepicker(chinaDateOptions)
        @ui.endDatePicker.datetimepicker(chinaDateOptions)
      else
        @ui.startDatePicker.datetimepicker(usDateOptions)
        @ui.endDatePicker.datetimepicker(usDateOptions)

      @ui.startDatePicker.on "dp.change", (e) =>
        @ui.endDatePicker.data("DateTimePicker").minDate(e.date);

      @ui.endDatePicker.on "dp.change", (e) =>
        @ui.startDatePicker.data("DateTimePicker").maxDate(e.date);

    createCampagin: ->
      this.model.attributes.deadline = $(".campaign_deadline_input").val()
      this.model.attributes.start_time = $(".campaign_start_time_input").val()
      @ui.form.data("formValidation").validate()

      this.model.save this.model.attributes,
        success: (m, r) ->
          console.log("成功了");
        error: (m, r) ->
          console.log("失败了");

    subtractionBudgetIcon: ->
      number = Number($(".budget_input").val())
      if number >= 1
        number -= 1
      $(".budget_input").val(number);

    subtractionPerBudgetIcon: ->
      number = Number($(".per_budget_input").val())
      if number >= 1
        number -= 1
      $(".per_budget_input").val(number);

    plusBudgetIcon: ->
      number = Number($(".budget_input").val()) + 1
      $(".budget_input").val(number);

    plusPerBudgetIcon: ->
      number = Number($(".per_budget_input").val()) + 1
      if number > Number($(".budget_input").val())
        number = Number($(".budget_input").val())
      $(".per_budget_input").val(number);