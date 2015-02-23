class PostWorker
  include Sidekiq::Worker

  def perform(post_id) 
    post = Post.find(post_id)
    user = post.user
    if post.social_networks[:twitter] == 'true'
      user.twitter_post(post.text) 
    end
    if post.social_networks[:linkedin] == 'true'
      user.linkedin_post(post.text) 
    end
    if post.social_networks[:facebook] == 'true'
      user.facebook_post(post.text) 
    end
  end
end