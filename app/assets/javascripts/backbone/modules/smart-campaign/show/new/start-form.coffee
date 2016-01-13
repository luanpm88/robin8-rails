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
      subtractionPerPostIcon: ".subtraction_per_post_icon"
      plusPerPostIcon: ".plus_per_post_icon"
      deadlineIcon: ".deadline_icon"
      doubleCheckCreate: ".double_check_create_campaign"
      campaignName: ".campaign_name_input"
      campaignDesc: ".campaign_desc_input"
      campaignUrl: ".campaign_url_input"
      campaignPerBudgetInput: ".per_budget_input"
      campaignBudgetInput: ".budget_input"
      campaignPerPostInput: ".per_post_input"
      campaignStartTimeInput: ".campaign_start_time_input"
      campaignEndTimeInput: ".campaign_deadline_input"

    events:
      "click @ui.createCampagin": "createCampagin"
      "click @ui.subtractionBudgetIcon": "subtractionBudgetIcon"
      "click @ui.plusBudgetIcon": "plusBudgetIcon"
      "click @ui.subtractionPerBudgetIcon": "subtractionPerBudgetIcon"
      "click @ui.plusPerBudgetIcon": "plusPerBudgetIcon"
      "click @ui.subtractionPerPostIcon": "subtractionPerPostIcon"
      "click @ui.plusPerPostIcon": "plusPerPostIcon"
      "click @ui.deadlineIcon": "deadlineIcon"
      "click @ui.doubleCheckCreate": "doubleCheckCreate"
      "change @ui.campaignName": "updateIsEdit"
      "change @ui.campaignDesc": "updateIsEdit"
      "change @ui.campaignUrl": "updateIsEdit"
      "change @ui.campaignBudgetInput": "updateIsEdit"
      "change @ui.campaignPerBudgetInput": "updateIsEdit"
      "change @ui.campaignStartTimeInput": "updateIsEdit"
      "change @ui.campaignEndTimeInput": "updateIsEdit"

    initialize: (options) ->
      @options = options
      @model = if @options.model? then @options.model else new Robin.Models.Campaign()
#      now = new Date
#      console.log @model
#      @model.attributes.start_time = now.setDate(now.getHours() + 2);
#      @model.attributes.deadline = now.setDate(now.getDate() + 2);
#      console.log @model
      @isEdit = false
      @modelBinder = new Backbone.ModelBinder()

    serializeData: ->
      campaign: this.model.toJSON()

    onRender: () ->
      if @model && @model.attributes["start_time"]
        start_time = new Date(@model.attributes.start_time).getTime() + 8*60*60
        end_time = new Date(@model.attributes.deadline).getTime() + 8*60*60
        @model.attributes.start_time = (new Date(start_time)).toString('yyyy-MM-dd HH:mm')
        @model.attributes.deadline = (new Date(end_time)).toString('yyyy-MM-dd HH:mm')
      @modelBinder.bind @model, @el
      _.defer =>
        @initDatepicker()
        @initFormValidation()
        @initQiniuUploader()
        @initCreateCampaignModal()

        $(".budget_input").focus()
        $(".campaign_name_input").focus()

    initCreateCampaignModal: ->
      if @model.attributes.per_post_budget != null
        $('input:radio[name="action_type"]').filter('[value=post]').prop('checked', true)
      else if @model.attributes.per_click_budget != null
        $('input:radio[name="action_type"]').filter('[value=click]').prop('checked', true)
      else
        $('input:radio[name="action_type"]').filter('[value=post]').prop('checked', true)

      $(".create-campaign-modal").on "hidden.bs.modal", (e)->
        $("#create-campagin").prop("disabled", false)
        $("#create-campagin").removeClass("disabled")

    doubleCheckCreate: ->
      $(".create-campaign-modal").modal("hide")
      parentThis = this
      parentThis.model.attributes.deadline = $(".campaign_deadline_input").val()
      parentThis.model.attributes.start_time = $(".campaign_start_time_input").val()
      parentThis.model.attributes.img_url = $('input[name=img_url]').val()
      if $('input[name=per_click_budget]').val()
        parentThis.model.attributes.per_click_budget = $('input[name=per_click_budget]').val()


      parentThis.model.attributes.per_click_budget = $('input[name=per_click_budget]').val()
      parentThis.model.attributes.budget = $('input[name=budget]').val()
      @ui.form.data("formValidation").validate()

      parentThis.model.save this.model.attributes,
        success: (m, r) ->
          $.growl polyglot.t("smart_campaign.start_step.create_campaign"), {type: "success"}
          $(".create-campaign-modal").modal("hide")
          location.href = "/#smart_campaign"
        error: (m, r) ->
          $(".create-campaign-modal").modal("hide")
          console.log("失败了");


    initQiniuUploader: ->
      uploader = Qiniu.uploader(
        runtimes: 'html5,flash,html4'
        browse_button: 'img-url-pick'
        uptoken_url: '/users/qiniu_uptoken'
        unique_names: true
        domain: '7xozqe.com1.z0.glb.clouddn.com'
        container: 'img-url-container'
        max_file_size: '100mb'
        flash_swf_url: 'js/plupload/Moxie.swf'
        max_retries: 3
        dragdrop: true
        drop_element: 'img-url-container'
        chunk_size: '4mb'
        auto_start: true
        filters: mime_types: [ {
          title: 'Image files'
          extensions: 'jpg,jpeg,gif,png'
        } ]
        init:
          'FilesAdded': (up, files) ->
            plupload.each files, (file) ->
              # 文件添加进队列后,处理相关的事情
              return
            return
          'BeforeUpload': (up, file) ->
            # 每个文件上传前,处理相关的事情
            return
          'UploadProgress': (up, file) ->
            # 每个文件上传时,处理相关的事情
            return
          'FileUploaded': (up, file, info) ->
            domain = up.getOption('domain')
            res = jQuery.parseJSON(info)
            imageView2 = '-400'
            sourceLink = 'http://' + domain + '/' + res.key + imageView2
            $('#campaign-image').attr 'src', sourceLink
            $('input[name=img_url]').val sourceLink
            #获取上传成功后的文件的Url
            return
          'Error': (up, err, errTip) ->
            #上传出错时,处理相关的事情
            return
          'UploadComplete': ->
            #队列文件处理完毕后,处理相关的事情
            return
      )


    initFormValidation: ->
      parentThis = @
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
        trigger: "blur"
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
              callback:
                message: polyglot.t('smart_campaign.validation.url_invalid')
                callback: (value, validator, $field) ->
                  RegExp = /^(http|https):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/;
                  if RegExp.test(value)
                    return true
                  return false
              notEmpty:
                message: polyglot.t('smart_campaign.validation.url')

          budget:
            validators:
              notEmpty:
                message: polyglot.t('smart_campaign.validation.budget')
              greaterThan:
                inclusive: false

                value: 0
                message:  polyglot.t('smart_campaign.validation.budget_should_greater_than_zero')
              integer:
                message: polyglot.t('smart_campaign.validation.budget_should_be_digit')

              remote:
                url: "/users/avail_amount"
                type: "get"
                delay: 300
                message: polyglot.t('smart_campaign.validation.budget_is_not_ample')
                data: (value, validators, $field) ->
                  @isEdit = true
                  if parentThis.model.id?
                    campaign_id = parentThis.model.id
                  else
                    campaign_id = 'no'
                  v =
                    amount: $('.budget_input').val(),
                    campaign_id: campaign_id
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
              greaterThan:
                inclusive: false
                value: 0
                message:  polyglot.t('smart_campaign.validation.per_click_budget_should_greater_than_zero')
              numeric:
                message: polyglot.t('smart_campaign.validation.per_click_budget_should_be_digit')
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
        .on 'err.validator.fv', (e, data) ->
          data.element
              .data('fv.messages')
              .find('.help-block[data-fv-for="' + data.field + '"]').hide()
              .filter('[data-fv-validator="' + data.validator + '"]').show();


    initDatepicker: ->
      now = new Date
      start_time = new Date(now.setHours(now.getHours() + 2));
      deadline = new Date(now.setDate(now.getDate() + 2));

      chinaStartDateOptions = {
        ignoreReadonly: true,
        format: 'YYYY-MM-DD HH:mm',
        locale: 'zh-cn',
        defaultDate: start_time
      }
      chinaEndDateOptions = {
        ignoreReadonly: true,
        format: 'YYYY-MM-DD HH:mm',
        locale: 'zh-cn',
        defaultDate: deadline
      }
      console.log chinaEndDateOptions
      usDateOptions = {
        ignoreReadonly: true,
        format: 'YYYY-MM-DD HH:mm',
        locale: 'en-gb',
        minDate: start_time
      }

      if Robin.chinaLocale
        @ui.startDatePicker.datetimepicker(chinaStartDateOptions)
        @ui.endDatePicker.datetimepicker(chinaEndDateOptions)
      else
        @ui.startDatePicker.datetimepicker(usDateOptions)
        @ui.endDatePicker.datetimepicker(usDateOptions)

      @ui.startDatePicker.on "dp.change", (e) =>
        @ui.endDatePicker.data("DateTimePicker").minDate(e.date);

      @ui.endDatePicker.on "dp.change", (e) =>
        @ui.startDatePicker.data("DateTimePicker").maxDate(e.date);

    updateIsEdit: ->
      @isEdit = true

    createCampagin: ->
      @ui.form.data("formValidation").validate()
      if @model.id?
        if @ui.form.data('formValidation').isValid()
          $(".create-campaign-modal").modal("show");
        else
          $("#create-campagin").removeClass("disabled");
          $("#create-campagin").prop('disabled', false);
      else
        if @ui.form.data('formValidation').isValid()
          $(".create-campaign-modal").modal("show");
        else
          $("#create-campagin").removeClass("disabled");
          $("#create-campagin").prop('disabled', false);

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

    subtractionPerPostIcon: ->
      number = Number($(".per_post_input").val())
      if number >= 1
        number -= 1
      $(".per_post_input").val(number);

    plusPerPostIcon: ->
      number = Number($(".per_post_input").val()) + 1
      $(".per_post_input").val(number);
