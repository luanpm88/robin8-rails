class CampaignShow < ActiveRecord::Base
  CookieTimeout = Rails.env.production? ? 30.minutes : 30.seconds

  scope :valid, ->{ where(:status => 1) }
  scope :by_date, ->(datetime) { where("created_at >= '#{datetime}' and created_at < '#{datetime + 1.day}'") }

  # 检查 campaign status
  def self.is_valid?(campaign, campaign_invite, uuid, visitor_cookies)
    if campaign.status == 'finished'
      return [false, 'campaign_had_finished']
    end

    #check status
    # if campaign_invite.status != 'approved'
    #   return [false, 'campaign_invite_not_approved']
    # end

    store_key = visitor_cookies
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
    campaign_invite = CampaignInvite.where(:uuid => uuid).first     rescue nil
    return false if campaign_invite.nil?  ||  campaign.nil?   || campaign_invite.status == 'running'
    status, remark = CampaignShow.is_valid?(campaign, campaign_invite, uuid, visitor_cookies)
    CampaignShow.create!(:kol_id => info['kol_id'], :campaign_id => info['campaign_id'], :visitor_cookie => visitor_cookies,
                        :visit_time => Time.now, :status => status, :remark => remark, :visitor_ip => visitor_ip)
    Rails.logger.campaign_show_sidekiq.info "---------CampaignShow add_click: --uuid:#{uuid}---status:#{status}----remark#{remark}---cid: #{campaign.id} --cinvite_id:#{campaign_invite.id}"
    add_result = campaign_invite.add_click(status)    rescue nil
    campaign.add_click(status)     if  add_result
  end
end
