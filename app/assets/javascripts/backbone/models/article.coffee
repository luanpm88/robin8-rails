Robin.Models.Article = Backbone.Model.extend
  urlRoot: '/article'
  url: ()->
    this.get("campaign_model").url() + this.urlRoot
