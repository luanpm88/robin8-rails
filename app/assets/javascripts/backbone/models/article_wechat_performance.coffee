Robin.Models.WechatArticlePerformance= Backbone.Model.extend
  urlRoot: () ->
    @article_model.url() + '/wechat_performance'

  initialize: (attributes, options) ->
    @article_model = options.article_model
