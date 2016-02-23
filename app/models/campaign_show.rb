class CampaignShow < ActiveRecord::Base
  CookieTimeout = Rails.env.production? ? 30.minutes : 30.seconds

  scope :valid, ->{ where(:status => 1) }
  scope :by_date, ->(datetime) { where("created_at >= '#{datetime}' and created_at < '#{datetime + 1.day}'") }

  # 检查 campaign status
  def self.is_valid?(campaign, campaign_invite, uuid, visitor_cookies)
    now = Time.now
    # check campaign status
    if campaign.status == 'executed'  ||  campaign.status == 'settled'
      return [false, 'campaign_had_executed']
    end

    #check status
    # if campaign_invite.status != 'approved'
    #   return [false, 'campaign_invite_not_approved']
    # end

    store_key = visitor_cookies.to_s + campaign.id.to_s
    # check_cookie?
    if Rails.cache.read(store_key)
      return [false, 'cookies_visit_fre']
    else
      Rails.cache.write(store_key, now, :expired_at => now + CookieTimeout)
    end

    kol = Kol.fetch_kol(campaign_invite.kol_id)
    # check kol's five_click_threshold
    if kol && kol.five_click_threshold
      store_key =  "five_click_threshold_#{campaign_invite.id}_#{now.min / 5}"
      current_five_click = Rails.cache.read(store_key)  || 0
      if current_five_click >= kol.five_click_threshold
        return [false, "exceed_five_click_threshold"]
      else
        Rails.cache.write(store_key, current_five_click + 1, :expires_in => 5.minutes)
      end
    end

    # check kol's total_click_threshold
    if kol && kol.total_click_threshold
      store_key =  "total_click_threshold_#{campaign_invite.id}"
      current_total_click = Rails.cache.read(store_key)  || 0
      if current_total_click >= kol.total_click_threshold
        return [false, "exceed_total_click_threshold"]
      else
        Rails.cache.write(store_key,current_total_click + 1, :expired_at => campaign.deadline)
      end
    end

    return [true,nil]
  end

  #TODO campaign  campaign_invite store in redis
  def self.add_click(uuid, visitor_cookies, visitor_ip, visitor_agent, visitor_referer)
    info = JSON.parse(Base64.decode64(uuid))   rescue {}
    campaign = Campaign.find_by :id => info['campaign_id']  rescue nil
    campaign_invite = CampaignInvite.where(:uuid => uuid).first     rescue nil
    if campaign_invite.nil?  ||  campaign.nil?   || ["running", "pending", "rejected"].include?(campaign_invite.status)
      Rails.logger.campaign_show_sidekiq.info "---------CampaignShow return: --uuid:#{uuid}---status:#{campaign_invite.status}---"
      return false
    end

    status, remark = CampaignShow.is_valid?(campaign, campaign_invite, uuid, visitor_cookies)
    CampaignShow.create!(:kol_id => info['kol_id'], :campaign_id => info['campaign_id'], :visitor_cookie => visitor_cookies,
                        :visit_time => Time.now, :status => status, :remark => remark, :visitor_ip => visitor_ip,
                        :visitor_agent => visitor_agent, :visitor_referer => visitor_referer)
    Rails.logger.campaign_show_sidekiq.info "---------CampaignShow add_click: --uuid:#{uuid}---status:#{status}----remark:#{remark}---cid: #{campaign.id} --cinvite_id:#{campaign_invite.id}"
    add_result = campaign_invite.add_click(status)    rescue nil
    campaign.add_click(status)     if  add_result
  end
end
