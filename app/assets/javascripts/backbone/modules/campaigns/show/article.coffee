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
      "comments": "#comments-list"
    events:
      "click #article-save": "save_data"
      "click #comment-save": "save_comment"
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
