class PushArticle
  include Mongoid::Document
  include Mongoid::Timestamps

  field :kol_id, type: Integer
  field :article_id, type: String
  field :article_url, type: String
  field :article_avatar_url, type: String
  field :article_title, type: String
  field :article_author, type: String

  # field :created_at, type: DateTime

  validates :kol_id, presence: true
  validates :article_id, presence: true

  def self.get_push_ids(kol_id)
    Rails.cache.fetch  kol_push_ids(kol_id) do
      recent_read_ids = ArticleAction.where(:kol_id => kol_id).where(:created_at.gte => 7.days.ago).collect{|t| t.article_id}   rescue []
      push_ids = PushArticle.where(:kol_id => kol_id).where(:created_at.gte => 7.days.ago).collect{|t| t.article_id}            rescue []
      (recent_read_ids + push_ids)[0,1200]
    end
  end

  def self.kol_push_ids(kol_id)
    "kol_push_ids_#{kol_id}"
  end

  #记录推荐的文章
  def self.kol_add_push_articles(kol_id,articles)
    #1. 存储到mongodb
    article_ids = []
    articles.each do |article|
      article_ids << article['id']
      PushArticle.create(:kol_id => kol_id, :article_id => article['id'], :created_at => Time.now)
    end
    #2. 更新到cache
    append_value(self.kol_push_ids(kol_id), article_ids)
  end
end
