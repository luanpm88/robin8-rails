class PostWorker
  include Sidekiq::Worker

  def perform(post_id)
    post = Post.find(post_id)
    user = post.user
    if post.twitter_ids.count > 0
      post.twitter_ids.each do |id|
        user.twitter_post(post.text, id)
      end
    end
    if post.linkedin_ids.count > 0
      post.linkedin_ids.each do |id|
        user.linkedin_post(post.text, id)
      end
    end
    if post.facebook_ids.count > 0
      post.facebook_ids.each do |id|
        user.facebook_post(post.text, id)
      end
    end
    if post.weibo_ids.count > 0
      post.weibo_ids.each do |id|
        user.weibo_post(post.text, id)
      end
    end
  end
end
