class MessageWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :message
  def perform(campaign_id , kol_ids)
  	Message.new_campaign(campaign_id, kol_ids)
  end
end