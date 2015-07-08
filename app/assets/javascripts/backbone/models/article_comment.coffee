Robin.Models.ArticleComment = Backbone.Model.extend
  urlRoot: ()->
    @article_model.url() + "/" + @article_model.get("id") + '/comments'

  initialize: (attributes, options) ->
    @article_model = options.article_model
