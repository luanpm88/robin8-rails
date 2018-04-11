class ElasticArticlesController < ApplicationController
	layout false

  def forward
  	@res = $redis.hgetall("elastic_#{params[:post_id]}")

  	if @res.empty?
    	res = ElasticArticleExtend.get_by_post_ids([params[:id]]).first
    	if res
    		$redis.hset("elastic_#{params[:post_id]}", 'avatar_url',   res['avatar_url'])
    		$redis.hset("elastic_#{params[:post_id]}", 'profile_name', res['profile_name'])
    		$redis.hset("elastic_#{params[:post_id]}", 'title', 			 res['title'])
    		$redis.hset("elastic_#{params[:post_id]}", 'pic_content',  res['pic_content'])
    		$redis.hset("elastic_#{params[:post_id]}", 'reads_count',  res['reads_count'])
    		$redis.hset("elastic_#{params[:post_id]}", 'likes',        res['likes'])
    		$redis.hset("elastic_#{params[:post_id]}", 'shares',       res['shares'])

    		@res = $redis.hgetall("elastic_#{params[:post_id]}")
    	else
    		render text: 'not_found'
    	end
    end
  end

end