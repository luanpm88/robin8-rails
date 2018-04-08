namespace :elastic_articles do

	task :reset_counts do
		ElasticArticleActions.all.group(:post_id).each do |post_id, ary|
			ea = ElasticArticle.find_or_initialize_by(post_id: post_id)

			ea.likes_count = $redis.hget("elastic_article_#{post_id}", 'like')
			ea.collects_count = $redis.hget("elastic_article_#{post_id}", 'collect')

			ea.save
		end
	end
			
end