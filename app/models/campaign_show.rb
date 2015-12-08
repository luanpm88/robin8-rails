class CampaignShow < ActiveRecord::Base
  CookieTimeout = Rails.env.production? ? 30.minutes : 30.seconds
  # 检查 campaign status
  def self.is_valid?(campaign, uuid, visitor_cookies)
    #check status
    if campaign.status != 'executing'
      return [false, 'campaign_finished']
    end

    store_key = uuid + visitor_cookies
    # check_cookie?
    if Rails.cache.read(store_key)
      return [false, 'cookies_visit_fre']
    end

    Rails.cache.write(store_key, Time.now, :expired_at => Time.now + CookieTimeout)
    return [true,nil]
  end

  #TODO campaign  campaign_invite store in redis
  def self.add_click(uuid, visitor_cookies, visitor_ip)
    info = JSON.parse(Base64.decode64(uuid))   rescue {}
    campaign = Campaign.find info['campaign_id']  rescue nil
    return false if campaign.nil?
    status, remark = CampaignShow.is_valid?(campaign, uuid, visitor_cookies)
    CampaignShow.create!(:kol_id => info['kol_id'], :campaign_id => info['campaign_id'], :visitor_cookie => visitor_cookies,
                        :visit_time => Time.now, :status => status, :remark => remark, :visitor_ip => visitor_ip)

    add_result = CampaignInvite.where(:uuid => uuid).first.add_click(status)    rescue nil
    campaign.add_click(status)     if  add_result
  end
end
