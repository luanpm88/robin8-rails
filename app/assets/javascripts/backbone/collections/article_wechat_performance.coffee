Robin.Collections.WechatArticlePerformances = Backbone.Collection.extend
  model: Robin.Models.WechatArticlePerformance
  url: () ->
    @article_model.url() + '/wechat_performance'

  initialize: (options) ->
    @article_model = options.article_model
