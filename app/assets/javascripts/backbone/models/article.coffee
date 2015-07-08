Robin.Models.Article = Backbone.Model.extend
  urlRoot: '/article'
  url: ()->
    this.get("campaign_model").url() + this.urlRoot

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
