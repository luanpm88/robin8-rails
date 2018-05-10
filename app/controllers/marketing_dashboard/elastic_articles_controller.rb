class MarketingDashboard::ElasticArticlesController < MarketingDashboard::BaseController

  def index
  	@q = ElasticArticle.ransack(params[:q])
    @elastic_articles = @q.result.order('updated_at DESC').paginate(paginate_params)
  end

  def kols
  	@q    = Kol.ransack(params[:q])
    @kols = @q.result.order('id DESC').paginate(paginate_params)
  end
  
end
