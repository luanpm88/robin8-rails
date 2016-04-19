class ArticleAction < ActiveRecord::Base
  #Action read:阅读  like:点赞  collect:收藏   forward:转发
  include Redis::Objects
  counter :redis_click

  scope :collect, ->{where(:collect => true)}
  scope :order_by_status, -> { order("forward desc, collect desc, 'like desc', look desc, created_at desc") }

  after_save :update_list, :on => :create

  # 取消喜欢的文章   action: read/collect
  def self.action_from_list(action, kol_id, params )
    article_action = ArticleAction.find_or_initialize_by(:kol_id => kol_id, :article_id => params[:article_id])
    #阅读 收藏
    if article_action.new_record?
      article_action.article_title = params[:article_title]
      article_action.article_url = params[:article_url]
      article_action.article_avatar_url  = params[:article_avatar_url]
      article_action.article_author = params[:article_author]
      article_action.send("#{action}=", true)
    elsif action == 'collect'        #如果已经收藏 则取消搜藏
      article_action.send("#{action}=", !self.send(action))
    else
      article_action.look = true
    end
    article_action.save
    article_action
  end

  def action(action)
    if action == 'forward'
      self.update_column("forward", true)
      self.forward = true
    else
      self.update_column("#{action}", !self.send(action))
    end
    self.reload
  end

  #存储所有action  当前为look
  def self.get_relation_ids(kol_id)
    articles = ArticleAction.where(:kol_id => kol_id).order_by_status.limit(20)
    articles.collect{|t| t.article_id}
  end

  def update_list
    if (self.look_changed? && self.look == true)  || (self.collect_changed? && self.collect == true)
      # 缓重置存的内容
      Articles::Store.reset_kol_articles(kol_id)
    end
  end

  def share_url
    "#{Rails.application.secrets.domain}/articles/#{self.id}/show"
  end

  def self.fetch_article_action(id)
    Rails.cache.fetch("article_action_#{id}") do
      ArticleAction.find id rescue nil
    end
  end

  def self.get_forward_info(kol_id)
    artilces =  ArticleAction.where(:kol_id => kol_id, :forward => true)
    article_count = artilces.count
    read_count = artilces.collect{|t| t.redis_click.value }.sum
    return  [article_count, read_count]
  end

end
