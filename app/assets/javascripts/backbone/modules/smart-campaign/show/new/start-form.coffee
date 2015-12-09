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

    events:
      "click @ui.createCampagin": "createCampagin"

    initialize: (options) ->
      @options = options
      @model = if @options.model? then @options.model else new Robin.Models.Campaign()
      @modelBinder = new Backbone.ModelBinder()

    onRender: () ->
      @modelBinder.bind @model, @el
      @initDatepicker()

    initDatepicker: ->
      chinaDateOptions = {
        ignoreReadonly: true,
        format: 'YYYY-MM-DD HH:mm',
        locale: 'zh-cn',
        minDate: new Date()
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

    createCampagin: ->
      console.log("123456789abcd");
      this.model.attributes.deadline = $(".campaign_deadline_input").val()
      this.model.attributes.start_time = $(".campaign_start_time_input").val()
      this.model.save this.model.attributes,
        success: (m, r) ->
          console.log("成功了");
        error: (m, r) ->
          console.log("失败了");