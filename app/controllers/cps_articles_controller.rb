class CpsArticlesController < Mobile::BaseController
  layout 'cps_article'

  def show
    @cps_article = CpsArticle.find params[:id]
    return render :text => 'article not found'   if @cps_article.blank?
    @cps_article.read_count.increment
  end

  def share_show
    @cps_share = CpsArticleShare.find params[:id]
    @cps_article = @cps_share.cps_article         rescue nil
    return render :text => 'article not found'    if @cps_article.blank?
    @cps_article.read_count.increment
    @cps_share.read_count.increment
    render :action => :show
  end

end

