class MessageWorker
  include Sidekiq::Worker
  def perform(campaign_id , kol_ids)
  	Message.new_campaign(campaign_id, kol_ids)
  end
end