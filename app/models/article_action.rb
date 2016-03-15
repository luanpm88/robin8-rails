class ArticleAction < ActiveRecord::Base
  #Action read:阅读  like:点赞  collect:收藏   forward:转发
  include Redis::Objects
  counter :redis_click

  scope :collect, ->{where(:collect => true)}

  after_save :update_list, :on => :create

  ChangeThreshold = 5

  def self.action_from_list(action, kol_id, params )
    article_action = ArticleAction.find_or_initialize_by(:kol_id => kol_id, :article_id => params[:article_id])
    if article_action.new_record?
      article_action.article_title = params[:article_title]
      article_action.article_url = params[:article_url]
      article_action.article_avatar_url  = params[:article_avatar_url]
      article_action.article_author = params[:article_author]
    end
    article_action.send("#{action}=", true)
    # article_action.instance_variable_set(:"@#{action}", true)
    article_action.save
    article_action
  end

  def action(action)
    self.send("#{action}=", !self.send(action))
    self.save
    self
  end

  #存储所有action
  def self.get_action_ids(kol_id, action)
    Rails.cache.fetch ArticleAction.kol_action_key(kol_id, action)  do
      articles = ArticleAction.where(:kol_id => kol_id).where("#{action} = '1'").order('id desc')
      articles.collect{|t| t.article_id}
    end
  end

  #存储所有action     key
  def self.kol_action_key(kol_id, action)
    "kol_#{action}_ids_#{kol_id}"
  end

  def update_list
    append_value(ArticleAction.kol_action_key(kol_id, 'read'), article_id)
    Articles::Store.reset_kol_articles(kol_id)
    # if self.read_changed? && self.read == true
      # count = Rails.cache.increment(ArticleAction.kol_action_key(kol_id, 'change'), 1)
      # if count > ChangeThreshold
      #   #1. 清空文章缓存
      #   Articles::Store.reset_kol_articles(kol_id)
      #   #2. 清除累积
      #   Rails.cache.delete(ArticleAction.kol_action_key(kol_id, 'change'))
      # end
    # end
  end

  def share_url
    "#{Rails.application.secrets.domain}/articles/#{self.id}/show"
  end

  def fetch_article_action(id)
    Rails.cache.fetch("article_action_#{id}") do
      ArticleAction.find id rescue nil
    end
  end

end
