Robin.Models.Article = Backbone.Model.extend
  urlRoot: () ->
    this.get("campaign_model").url() + '/article'

  fetch_comments: (callback)->
    comments = new Robin.Collections.ArticleComments
      article_model: @
    comments.fetch
      success: ()=>
        @.set
          article_comments: comments
        callback?()
      error: (e)->
        console.log e

  approve: (callback) ->
    $.post "#{@urlRoot()}/#{@id}/approve", (data) -> callback? data

  approve_request: (callback) ->
    $.post "#{@urlRoot()}/#{@id}/approve_request", (data) -> callback? data
