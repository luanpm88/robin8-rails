class MarketingDashboard::ElasticArticlesController < MarketingDashboard::BaseController

  def index
  	@q = ElasticArticle.includes(:tag).ransack(params[:q])
    @elastic_articles = @q.result.order('updated_at DESC').paginate(paginate_params)
  end

  def kols
  	# @q    = Kol.ransack(params[:q])
  	@q 		= Kol.joins(:elastic_article_actions).where("kols.id=elastic_article_actions.kol_id").ransack(params[:q])
    @kols = @q.result.uniq.order('id DESC').paginate(paginate_params)
  end

  def kols_red_money
  	@q		= Kol.joins(:transactions).where("transactions.account_type='Kol' and transactions.subject='red_money' and kols.id=transactions.account_id").ransack(params[:q])
    @kols = @q.result.uniq.order('id DESC').paginate(paginate_params)
  end
  
end
