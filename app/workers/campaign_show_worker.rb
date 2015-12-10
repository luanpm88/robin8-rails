class CampaignShowWorker
  include Sidekiq::Worker
  sidekiq_options  :queue => :campaign_show

  def perform(invite_uuid, visitor_cookies, visitor_ip)
    puts invite_uuid
    puts visitor_cookies
    puts visitor_ip
    CampaignShow.add_click(invite_uuid, visitor_cookies, visitor_ip)
  end
end
