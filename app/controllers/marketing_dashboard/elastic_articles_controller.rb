class MarketingDashboard::ElasticArticlesController < MarketingDashboard::BaseController

  def index
  	@q = ElasticArticle.ransack(params[:q])
    @elastic_articles = @q.result.order('updated_at DESC').paginate(paginate_params)
  end

  def kols
  end
  
end
