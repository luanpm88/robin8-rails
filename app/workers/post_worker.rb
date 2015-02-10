class PostWorker
  include Sidekiq::Worker

  def perform()
    p '~'*90
    p 'inside worker'
    # if post.social_networks[:twitter] == 'true'
    #   user = post.user
    #   user.twitter_post(post.text) 
    # end
  end
end