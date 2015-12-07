class CampaignShow < ActiveRecord::Base
  CookieTimeout = 30.minutes
  # 检查 campaign status
  def self.is_valid?(campagin, visitor_cookies)
    #check status
    if campagin.status != 'executing'
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
  def add_click(uuid, visitor_cookies, visitor_ip)
    info = Base64.decode(uuid)
    campagin = Campaign.find info[:campagin_id]  rescue nil
    return false if campagin.nil?
    status, remark = CampaignShow.is_valid?(campagin,visitor_cookies)
    CampaignShow.create(:kol_id => info[:kol_id], :campagin_id => info[:campagin_id], :visitor_cookie => visitor_cookie,
                        :visit_time => Time.now, :stauts => stauts, :remark => remark, :visitor_ip => visitor_ip)

    CampaignInvite.where(:uuid => uuid).add_click(uuid , status)
    campagin.add_click(status)
  end
end
