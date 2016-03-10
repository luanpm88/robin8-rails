class ArticleAction < ActiveRecord::Base
  #Action read:阅读  like:点赞  collect:收藏   forward:转发

  after_commit :update_list

  ChangeThreshold = 5
  def self.article_action(kol_id, action, params )
    article_action = ArticleAction.find_or_initialize_by(:action => action, :kol_id => kol_id, :article_id => params[:article_id])
    if article_action.new_record?
      article_action.article_title = params[:article_title]
      article_action.article_url = params[:article_url]
      article_action.article_avatar_url  = params[:article_avatar_url]
      article_action.article_author = params[:article_author]
      article_action.save
    end
  end

  #存储所有action
  def self.get_action_ids(kol_id, action)
    Rails.cache.fetch ArticleAction.kol_action_key(kol_id, action)  do
      articles = ArticleAction.where(:kol_id => kol_id, :action => action).order('id desc')
      articles.collect{|t| t.article_id}
    end
  end

  #存储所有action     key
  def self.kol_action_key(kol_id, action)
    "kol_#{action}_ids_#{kol_id}"
  end

  def update_list
    append_value(ArticleAction.kol_action_key(kol_id, action), article_id)
    count = Rails.cache.increment(ArticleAction.kol_action_key(kol_id, 'change'), 1)
    if count > ChangeThreshold
      #1. 清空文章缓存
      Article::Store.reset_kol_articles(kol_id)
      #2. 清除累积
      Rails.cache.write(ArticleAction.kol_action_key(kol_id, 'change'), 0)
    end

  end

end
