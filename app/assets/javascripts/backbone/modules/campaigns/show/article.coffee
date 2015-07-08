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

    serializeData: () ->
      item: @model.toJSON()
      title: @options.title

    onRender: () ->
      @ui.wysihtml5.wysihtml5()
      @editor = @ui.wysihtml5.data('wysihtml5').editor
      @editor.focus()

    save_data: () ->
      @model.set
        text: @editor.getValue()
      @model.save()

    save_comment: ()->
      comment = new Robin.Models.ArticleComment(
        {
          text: @ui.commentInput.val()
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
