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
#      comments = new Robin.Collections.ArticleComments
#        article_model: @model
#      comments.fetch
#        success: ()=>
#          @model.set
#            article_comments: comments
#        error: (e)->
#          console.log e

    save_data: () ->
      @model.set
        text: @editor.getValue()
      @model.save()

    save_comment: ()->
      model = new Robin.Models.ArticleComment
        text: $(@ui.commentInput).val()
        article_model: @model
      model.save
        success: ()=>
          $(@ui.commentInput).val('')
          comments = @model.get("article_comments")
          comments.push(model.toJSON())
          @model.set
            article_comments: comments
        error: (e)->
          console.log e
