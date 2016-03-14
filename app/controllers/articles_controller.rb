class ArtilesController < ApplicationController
  skip_before_action  :only => [:show, :share]

  def show
    article_action = ArticleAction.fetch_article_action(params[:id])
    if article_action.blank?
      render :text => "查看的文章不存在"
    else
      article_action.redis_click.increment
      redirect_to article_action.article_url
    end
  end

end
