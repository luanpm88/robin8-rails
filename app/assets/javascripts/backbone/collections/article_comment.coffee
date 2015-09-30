Robin.Collections.ArticleComments = Backbone.Collection.extend
  model: Robin.Models.ArticleComment
  url: () ->
    @article_model.url() + '/comments'

  initialize: (options) ->
    @article_model = options.article_model
