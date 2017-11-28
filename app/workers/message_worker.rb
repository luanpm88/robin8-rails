class MessageWorker
  include Sidekiq::Worker
  def perform(campaign , kol_ids)
  	Message.new_campaign(campaign, kol_ids)
  end
end