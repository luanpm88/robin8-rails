class NewQuoteWorker
  include Sidekiq::Worker


  def perform(email, url)
    UserMailer.new_quote(email, url).deliver_now
  end

end
