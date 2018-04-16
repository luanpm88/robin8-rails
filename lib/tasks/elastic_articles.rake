# encoding: utf-8
namespace :elastic_articles do

	task :reset_counts => :environment do
		p "&" * 100
		ElasticArticleAction.all.group_by{|ea| ea.post_id}.each do |post_id, ary|
			ea = ElasticArticle.find_or_initialize_by(post_id: post_id)
			_ary = ary.collect{|ele| ele._action}
			p _ary
			ea.likes_count 		= _ary.count('like')
			ea.collects_count = _ary.count('collect')
			ea.forwards_count = _ary.count('forward')
			p "*" * 100
			p ea
			ea.save
		end
	end
			
end
