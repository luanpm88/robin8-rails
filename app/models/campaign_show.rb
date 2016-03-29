class CampaignShow < ActiveRecord::Base
  CookieTimeout = Rails.env.production? ? 30.minutes : 3.seconds
  IpTimeout = Rails.env.production? ? 3.minutes : 3.seconds

  scope :valid, ->{ where(:status => 1) }
  scope :by_date, ->(datetime) { where("created_at >= '#{datetime}' and created_at < '#{datetime + 1.day}'") }
  scope :today, -> {where(:created_at => Time.now.beginning_of_day..Time.now.end_of_day)}

  # 检查 campaign status
  def self.is_valid?(campaign, campaign_invite, uuid, visitor_cookies, visitor_ip, visitor_agent, visitor_referer, options={})
    now = Time.now
    # check campaign status
    if campaign.status == 'executed'  ||  campaign.status == 'settled'
      return [false, 'campaign_had_executed']
    end

    if campaign.is_cpa?
      return [false, 'is_first_step_of_cpa_campaign'] if options[:step] != 2
      if options[:step] == 2 and campaign_invite.blank?
        return [false, "the_first_step_not_exist_of_cpa_campaign"]
      end
    end

    # check_cookie?
    store_key = visitor_cookies.to_s + campaign.id.to_s
    if Rails.cache.read(store_key)
      return [false, 'cookies_visit_fre']
    else
      Rails.cache.write(store_key, now, :expires_in => CookieTimeout)
    end

    # check_ip?
    store_key = visitor_ip.to_s + campaign.id.to_s
    if Rails.cache.read(store_key)
      return [false, 'ip_visit_fre']
    else
      Rails.cache.write(store_key, now, :expires_in => IpTimeout)
    end

    # check_useragent?  &&   visitor_referer
    return [false, 'visitor_agent_is_invalid']  if visitor_agent.blank?
    return [false, 'visitor_referer_exist']  if visitor_referer.present?

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

    # check visitor ip
    ip_score = IpScore.fetch_ip_score(visitor_ip)
    if ip_score.to_i < 60
      return [false, "ip_score_low"]
    end

    return [true,nil]
  end

  #TODO campaign  campaign_invite store in redis
  def self.add_click(uuid, visitor_cookies, visitor_ip, visitor_agent, visitor_referer, options={})
    options.symbolize_keys!

    info = JSON.parse(Base64.decode64(uuid))   rescue {}
    campaign = Campaign.find_by :id => info['campaign_id']  rescue nil

    if campaign.is_cpa?
      if (options[:step].to_i == 2 or info["step"].to_i == 2)
        campaign_invite_id = Rails.cache.fetch(visitor_cookies + ":cpa_campaign_id:#{campaign.id}")
        campaign_invite = CampaignInvite.find_by :id => campaign_invite_id if campaign_invite_id
      else
        campaign_invite = CampaignInvite.where(:uuid => uuid).first  rescue nil
        expired_at = (campaign.deadline > Time.now ? campaign.deadline : Time.now)
        Rails.cache.write(visitor_cookies + ":cpa_campaign_id:#{campaign.id}", campaign_invite.id, :expired_at => expired_at) if campaign_invite
      end
    else
      campaign_invite = CampaignInvite.where(:uuid => uuid).first     rescue nil
    end

    return false if campaign_invite.nil?  ||  campaign.nil?   || ["running", "pending", "rejected"].include?(campaign_invite.try(:status))

    status, remark = CampaignShow.is_valid?(campaign, campaign_invite, uuid, visitor_cookies, visitor_ip, visitor_agent,visitor_referer,  options)
    CampaignShow.create!(:kol_id => info['kol_id'], :campaign_id => info['campaign_id'], :visitor_cookie => visitor_cookies,
                        :visit_time => Time.now, :status => status, :remark => remark, :visitor_ip => visitor_ip,
                        :visitor_agent => visitor_agent, :visitor_referer => visitor_referer)
    Rails.logger.campaign_show_sidekiq.info "---------CampaignShow add_click: --uuid:#{uuid}---status:#{status}----remark:#{remark}---cid: #{campaign.id} --cinvite_id:#{campaign_invite.id}"
    campaign_invite.add_click(status,campaign)
    campaign.add_click(status)
  end
end
