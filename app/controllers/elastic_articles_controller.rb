class ElasticArticlesController < ApplicationController
	layout false

  def forward
  	@res = $redis.hgetall("elastic_#{params[:id]}")

  	if @res.empty?
    	res = ElasticArticleExtend.get_by_post_ids([params[:id]]).first
    	if res
    		$redis.hset("elastic_#{params[:id]}", 'avatar_url',   res['avatar_url'])
    		$redis.hset("elastic_#{params[:id]}", 'profile_name', res['profile_name'])
    		$redis.hset("elastic_#{params[:id]}", 'title', 			 res['title'])
    		$redis.hset("elastic_#{params[:id]}", 'pic_content',  res['pic_content'])
    		$redis.hset("elastic_#{params[:id]}", 'reads_count',  res['reads_count'])
    		$redis.hset("elastic_#{params[:id]}", 'likes',        res['likes'])
    		$redis.hset("elastic_#{params[:id]}", 'shares',       res['shares'])

    		$redis.expire("elastic_#{params[:id]}", 36000)

    		@res = $redis.hgetall("elastic_#{params[:id]}")
    	else
    		render text: 'not_found'
    	end
    end
  end

end