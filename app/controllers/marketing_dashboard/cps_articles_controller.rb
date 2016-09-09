class MarketingDashboard::CpsArticlesController < MarketingDashboard::BaseController
  def index
    authorize! :read, CpsArticle
    @q = CpsArticle.ransack(params[:q])
    @cps_articles = @q.result.includes(:kol, :cps_promotion_orders, :cps_materials).order('created_at desc').paginate(paginate_params)
  end

  def create
    authorize! :update, CpsArticle
    redirect_to :action => :index
  end

  def edit
    authorize! :read, CpsArticle
    @cps_article = CpsArticle.find params[:id]
  end

  def cps_materials
    authorize! :read, CpsArticle
    @cps_article = CpsArticle.find params[:id]
    @cps_materials =  @cps_article.cps_materials
    render 'marketing_dashboard/cps_materials/index'
  end

  def cps_article_shares
    authorize! :read, CpsArticle
    @cps_article = CpsArticle.find params[:id]
    params[:q] = {}    if params[:q].blank?
    params[:q][:cps_article_id_eq] = @cps_article.id
    @q = CpsArticleShare.ransack(params[:q])
    @cps_article_shares = @q.result.paginate(paginate_params)
  end

  def update
    authorize! :read, CpsArticle
    params.permit!
    @cps_article = CpsArticle.find params[:id]
    if @cps_article.update_attributes(params[:cps_article])
      redirect_to :action => :index
    else
      flash[:error] = "保存失败"
      render :action => :edit
    end
  end

end
