class CampaignShowWorker
  include Sidekiq::Worker
  sidekiq_options  :queue => :campaign_show

  def perform(invite_uuid, visitor_cookies, visitor_ip)
    Rails.logger.campaign_show_sidekiq.info "---------CampaignShowWorker --- #{invite_uuid} --- #{visitor_cookies} - #{visitor_ip}"
    CampaignShow.add_click(invite_uuid, visitor_cookies, visitor_ip)
  end
end
