Robin.module 'Campaigns.Show', (Show, App, Backbone, Marionette, $, _)->

  Show.ArticleDialog = Backbone.Marionette.LayoutView.extend
    template: 'modules/campaigns/show/templates/article-layout'
    templateHelpers:
      formatDate: (d) ->
        date = new Date d
        date.toLocaleFormat '%d-%b-%Y'
      timestamp: (d) ->
        date = new Date d
        date.getTime()
    regions:
      comments: "#comments-list"
      weChat: "#wechat-performance"
      imagesRegion: '.images_region'
    events:
      "click #article-save": "save_data"
      "click #comment-save": "save_comment"
      "click #article-approve": "approve_data"
      "click #wechat_perf_save": "wechat_perf_save"
      "click #wechat_claim": "wechat_claim"
    ui:
      wysihtml5: 'textarea.wysihtml5'
      commentInput: 'input#comment'
      errorBlock: 'p#comment-error'
      table: "#wechat-perf-table"
      form: "#wechat-perf-form"
      reached_peoples: "input#reached"
      page_views: "input#page_views"
      read_more: "input#read_more"
      favourite: "input#favourite"

    serializeData: () ->
      item: @model.toJSON()
      title: @options.title
      disabled: @options.disabled
      no_tabs: if @options.no_tabs then @options.no_tabs else false
      negotiating: @options.negotiating
      accepted: @options.accepted

    onRender: () ->
      no_comments = if @options.no_comments then @options.no_comments else false
      @ui.wysihtml5.wysihtml5()
      @editor = @ui.wysihtml5.data('wysihtml5').editor
      @editor.focus()
      setTimeout(()=>
        if @options.accepted == false and @options.negotiating == false
          document.getElementById('comment').style.display = "none"
        if @options.accepted == false
          document.getElementById('wechat_perf').style.display = "none"
        if @options.disabled || @options.no_tabs || (@options.accepted == false and @options.negotiating == false)
          @editor.disable()
        if no_comments
          @ui.commentInput.prop("disabled",true)
        @fileWidget = uploadcare.MultipleWidget('[role=uploadcare-uploader][data-multiple][data-file]')
        @.$el.find(".comments-title .image-preview-multiple-plus .uploadcare-widget-button-open").text("").addClass("btn glyphicon glyphicon-plus")
        @fileWidget.onChange (fileGroup) =>
          if (fileGroup)
            $.when.apply(null, fileGroup.files()).done () =>
              crop = '-/scale_crop/160x160/center/'
              arr = _.clone @model.get('attachments_attributes') || []
              _.each(arguments, (value, key) =>
                if !_.find(arr, (item) -> item.url == value.cdnUrl)
                  arr.push
                    url: value.cdnUrl
                    attachment_type: 'file'
                    name: value.name
                    thumbnail: value.cdnUrl + crop
              ,this)
              @model.set('attachments_attributes', arr)
              @model.save()
              @fileWidget.value null
        , 0)
      @ui.form.ready(_.bind @initFormValidation, @)
      if !@options.disabled
        @initImageUpload()

    initImageUpload: () ->
      @imagesRegion.show new Robin.Views.ImagesCollectionView
        model: @model
        collection: new Robin.Collections.Attachments()
        childView: Robin.Views.ImagesItemView

    save_data: () ->
      if @options.disabled
        @model.approve (data) =>
          $.growl
            message: "Article has been approved. Tracking code is  #{data.code}."
           ,
            type: "success"
          @options.onApprove? data.code
      else
        @model.set
          text: @editor.getValue()
        @model.save {},
          success: (m) ->
            $.growl
              message: "Saved!"

    approve_data: ()->
      current_text = @editor.getValue()
      if @model.text != current_text
        @model.set
          text: @editor.getValue()
        @model.save {},
          success: (m) ->
            $.growl
              message: "Article saved!"
      @model.approve_request (data) =>
        $.growl
            message: "Request for article approval sent"
           ,
            type: "success"
        $("#modal").modal("hide")

    save_comment: ()->
      text = @ui.commentInput.val()
      if !text
        @ui.commentInput.parent().addClass("has-error")
        @ui.errorBlock.removeClass("hidden")
        return
      else if @ui.commentInput.parent().hasClass("has-error")
        @ui.commentInput.parent().removeClass("has-error")
        @ui.errorBlock.addClass("hidden")
      comment = new Robin.Models.ArticleComment(
        {
          text: text
        },{
          article_model: @model
        })

      comment.save({},
        {
        success: ()=>
          @ui.commentInput.val('')
          comments = @model.get("article_comments")
          comments.add(comment,
            at: 0
          )
          @model.set
            article_comments: comments
          commentsList = new Show.ArticleComments
            collection: comments
          @showChildView 'comments', commentsList

        error: (e)->
          console.log e
        }
      )

    wechat_perf_save: ()->
      @ui.form.data('formValidation').validate()
      hasAttaches = false
      attaches = if @model.get('attachments_attributes')? then @model.get('attachments_attributes') else []
      $.each attaches, (index, value) ->
        if value.attachment_type == 'image'
          hasAttaches = true
      if !hasAttaches
        $.growl
          message: "Please upload screenshot of your WeChat page with related post."
         ,
          type: "danger"
      if @ui.form.data('formValidation').isValid() && hasAttaches
        wechat_perf = new Robin.Models.WechatArticlePerformance(
          {
            reached_peoples: @ui.reached_peoples.val()
            page_views: @ui.page_views.val()
            read_more: @ui.read_more.val()
            favourite: @ui.favourite.val()
            attachments_attributes: @model.get('attachments_attributes')
          },{
            article_model: @model
          })

        wechat_perf.save({},
          {
          success: ()=>
            @ui.reached_peoples.val('')
            @ui.page_views.val('')
            @ui.read_more.val('')
            @ui.favourite.val('')
            wechat_perfs = @model.get("wechat_performance")
            wechat_perfs.add(wechat_perf,
              at: 0
            )
            @model.set
              wechat_perfs: wechat_perf
            wechat_perfsList = new Show.ArticleWeChat
              collection: wechat_perfs
              disabled: false
              canUpload: false
            @showChildView 'weChat', wechat_perfsList
            if !@options.disabled
              @initImageUpload()

          error: (e)->
            console.log e
          }
        )
    wechat_claim: (e) ->
      reportId = e.target.attributes["report"].value
      reportPeriod = e.target.attributes["period"].value
      $('#campaign-article-modal').modal('hide')
      $('body').removeClass('modal-open')
      $('.modal-backdrop').remove()
      $('.fade').remove()
      weChatCliamDialog = new Show.ClaimReportDialog
        model: @model
        reportId: reportId
        reportPeriod: reportPeriod
      Robin.modal.show weChatCliamDialog

    initFormValidation: () ->
      @ui.form.formValidation(
        framework: 'bootstrap',
        excluded: [':disabled', ':hidden'],
        icon:
          valid: 'glyphicon glyphicon-ok'
          invalid: 'glyphicon glyphicon-remove'
          validating: 'glyphicon glyphicon-refresh'
        fields:
          reached:
            validators:
              notEmpty:
                message: 'Required field'
          page_views:
            validators:
              notEmpty:
                message: 'Required field'
          read_more:
            validators:
              notEmpty:
                message: 'Required field'
          favourite:
            validators:
              notEmpty:
                message: 'Required field'
      )
