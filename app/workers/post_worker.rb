class PostWorker
  include Sidekiq::Worker

  def perform()
    p '~'*90
    p 'inside worker'
  end
end