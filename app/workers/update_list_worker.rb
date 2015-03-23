require "mailgun"
class UpdateListWorker
  include Sidekiq::Worker

  def perform(post_id) 
    mg_client = Mailgun::Client.new Rails.application.secrets.mailgun[:api_key]
  end
end