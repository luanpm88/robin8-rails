class MarketingDashboard::ArticleContentsController < MarketingDashboard::BaseController
  def index
    authorize! :read, CpsArticle
    @q = ArticleContent.ransack(params[:q])
    @article_contents = @q.result.includes(:article_category).order('created_at desc').paginate(paginate_params)
  end

  def sync
    @article_content = ArticleContent.find params[:id]
    if @article_content.is_sync != true
      @article_content.update_column(:is_sync, true)
      CpsArticle.create!(kol_id: 60504, title: @article_content.title, cover: @article_content.cover, content: @article_content.content, :status => 'pending')
      flash[:notice] = '同步成功'
    end
    redirect_to :action => :index
  end

end
