module Articles
  class Recommend
    #发现文章列表
    DefaultSize = 24
    MaxSize = 120
    PerPage = 12
    TimeOut = 200

    RecommendUrl = "#{Rails.application.secrets[:recommend_server]}:5001/search/v1.1/wechat/recommend"
    def self.get_recommend_list(kol_id)
      kol_push_id = PushArticle.get_push_ids(kol_id)
      relation_ids = ArticleAction.get_relation_ids(kol_id)
      params = {ids:relation_ids, push_ids: kol_push_id, from: 0, size: PerPage }
      res = RestClient.post RecommendUrl, params.to_json, :content_type => :json, :accept => :json, :timeout => TimeOut   rescue ""
      articles = JSON.parse(res)["articles"]
      PushArticle.kol_add_push_articles(kol_id, articles)
      articles
    end

    SearchUrl =  "#{Rails.application.secrets[:recommend_server]}:5001/search/v1.1/wechat/search"
    def self.get_search_list(title = nil, page = 1)
      params = {keywords:[title], from: (page - 1) * PerPage, size: PerPage }
      res = RestClient.post SearchUrl, params, :timeout => TimeOut         rescue ""
      JSON.parse(res)["articles"]                               rescue []
    end

  end
end
