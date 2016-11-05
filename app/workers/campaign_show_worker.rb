class CampaignShowWorker
  include Sidekiq::Worker
  sidekiq_options  :queue => :campaign_show

  def perform(invite_uuid, visitor_cookies, visitor_ip, visitor_agent, visitor_referer, proxy_ips, request_uri, openid, visit_time, other_options={})
    start = Time.now
    Rails.logger.campaign_show_sidekiq.info "\n=============CampaignShowWorker --- #{invite_uuid} --- #{visitor_cookies} - #{visitor_ip} - #{visitor_agent} - #{visitor_referer} -#{visit_time}- #{other_options}"
    CampaignShow.add_click(invite_uuid, visitor_cookies, visitor_ip, visitor_agent, visitor_referer, proxy_ips, request_uri, openid, visit_time, other_options)
    Rails.logger.campaign_show_sidekiq.info "===========method invoke time :#{Time.now - start }"
  end
end
