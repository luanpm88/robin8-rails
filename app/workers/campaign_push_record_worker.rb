class CampaignPushRecordWorker
  include Sidekiq::Worker

  def perform(campaign_id, type=nil, kols=[])
    @campaign = Campaign.find(campaign_id) rescue nil

  end

end
