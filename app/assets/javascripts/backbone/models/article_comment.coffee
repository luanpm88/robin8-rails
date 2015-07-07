Robin.Models.ArticleComment = Backbone.Model.extend
  urlRoot: '/comments'
  url: ()->
    this.get("article_model").url() + "/" + this.get("article_model").get("id") + this.urlRoot
