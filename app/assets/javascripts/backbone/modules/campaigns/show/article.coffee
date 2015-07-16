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
    events:
      "click #article-save": "save_data"
      "click #comment-save": "save_comment"
      "click #article-approve": "approve_data"
    ui:
      wysihtml5: 'textarea.wysihtml5'
      commentInput: 'input#comment'
      errorBlock: 'p#comment-error'

    serializeData: () ->
      item: @model.toJSON()
      title: @options.title
      disabled: @options.disabled

    onRender: () ->
      @ui.wysihtml5.wysihtml5()
      @editor = @ui.wysihtml5.data('wysihtml5').editor
      @editor.focus()
      @editor.disable() if @options.disabled
      setTimeout(()=>
        @fileWidget = uploadcare.MultipleWidget('[role=uploadcare-uploader][data-multiple][data-file]')
        @.$el.find(".image-preview-multiple-plus .uploadcare-widget-button-open").text("").addClass("btn glyphicon glyphicon-plus")
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

    save_data: () ->
      if @options.disabled
        @model.approve (data) =>
          $.growl
            message: "Article approved. Tracking code is #{data.code}."
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
            message: "Request for article approving send"
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
