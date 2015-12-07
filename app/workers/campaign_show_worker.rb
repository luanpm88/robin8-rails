class CampaignShowWorker
  include Sidekiq::Worker
  idekiq_options  :queue => :campaign_show

  def perform(invite_uuid, visitor_cookies, visitor_ip)
    CampaignShow.add_click(invite_uuid, visitor_cookies, visitor_ip)
  end
end
