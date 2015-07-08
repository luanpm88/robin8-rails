Robin.Models.ArticleComment = Backbone.Model.extend
  urlRoot: ()->
    @article_model.url() + '/comments'

  initialize: (attributes, options) ->
    @article_model = options.article_model
