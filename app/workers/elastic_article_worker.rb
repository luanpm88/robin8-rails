class ElasticArticleWorker
  include Sidekiq::Worker
  sidekiq_options queue: :elastic_article_worker

  def self.perform(res=[])
    res.each do |ele|
      ea = ElasticArticle.find_or_initialize_by(post_id: ele['post_id'])
      if ea.new_record?
        ea.title = ele['title'][0,100]
        ea.tag = Tag.find_by_name(ele['top_industry'])
        ea.save
      end
    end
  end
end