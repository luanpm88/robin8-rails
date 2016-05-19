class CampaignShowWorker
  include Sidekiq::Worker
  sidekiq_options  :queue => :campaign_show

  def perform(invite_uuid, visitor_cookies, visitor_ip, visitor_agent, visitor_referer, proxy_ips, other_options={})
    Rails.logger.campaign_show_sidekiq.info "\n=============CampaignShowWorker --- #{invite_uuid} --- #{visitor_cookies} - #{visitor_ip} - #{visitor_agent} - #{visitor_referer} - #{other_options}"
    CampaignShow.add_click(invite_uuid, visitor_cookies, visitor_ip, visitor_agent, visitor_referer, other_options, proxy_ips)
  end
end
