class CampaignShow < ActiveRecord::Base
  include Concerns::CampaignShowForCpi
  CookieTimeout = Rails.env.production? ? 45.minutes : 5.seconds
  OpenidMaxCount = Rails.env.production? ? 1 : 10
  IpTimeout = Rails.env.production? ? 30.seconds : 5.seconds
  IpMaxCount = Rails.env.production? ? 20 : 40
  CampaignExecuted = 'campaign_had_executed'

  if Rails.env.production?
    KolCreditLevels = {'A' => 100, 'B' => 50, 'C' => 10, 'S' => 5000}
  else
    KolCreditLevels = {'A' => 4, 'B' => 1, 'C' => 10, 'S' => 5000}
  end

  belongs_to :campaign
  scope :valid, ->{ where(:status => 1) }
  scope :by_date, ->(datetime) { where("created_at >= '#{datetime}' and created_at < '#{datetime + 1.day}'") }
  scope :today, -> {where(:created_at => Time.now.beginning_of_day..Time.now.end_of_day)}
  scope :invite_need_settle, ->(campaign_id,kol_id,settle_deadline) {where("created_at <= '#{settle_deadline}'").where("transaction_id is null").where(:status => 1, :campaign_id => campaign_id, :kol_id => kol_id)}

  # 检查 campaign status
  def self.is_valid?(campaign, campaign_invite, uuid, visitor_cookies, visitor_ip, visitor_agent, visitor_referer, proxy_ips, request_uri, openid, visit_time, options={})
    return [false, 'over_max_click']   if campaign.redis_avail_click.value.to_i >= campaign.max_action.to_i
    visit_time = visit_time.to_time
    if visitor_ip.start_with?("101.226.103.6") ||  visitor_ip.start_with?("101.226.103.7")
      return [false, 'wechat_crawler']
    end

    if campaign.wechat_auth_type != 'no' && openid.blank?  && options[:step] != 2
      return [false, 'had_no_openid']
    end

    # check_useragent?  &&   visitor_referer
    return [false, 'visitor_agent_is_invalid']  if visitor_agent.blank? || !visitor_agent.include?("MicroMessenger")
    return [false, 'visitor_referer_exist']    if visitor_referer.present? and !campaign.is_cpa_type?

    cpa_first_step_key = nil
    if campaign.is_cpa_type?
      cpa_first_step_key = "cookies" + visitor_cookies.to_s + campaign.id.to_s
      if options[:step] != 2
        if openid
          expiry_time = (campaign.deadline.to_time - DateTime.now.to_time).to_i rescue 5*3600*24
          begin
            Rails.cache.write(cpa_first_step_key, openid, :expires_in => expiry_time.seconds)
          rescue Redis::CommandError
            Rails.cache.write(cpa_first_step_key, openid, :expires_in => 30.hours)
          end
        end
        return [false, 'is_first_step_of_cpa_campaign']
      end
      if options[:step] == 2 and campaign_invite.blank?
        return [false, "the_first_step_not_exist_of_cpa_campaign"]
      end
      if options[:step] == 2 and not (openid = Rails.cache.fetch(cpa_first_step_key))
        return [false, "the_two_step_has_not_openid_of_cpa_campaign"]
      end
    end

    # openid_reach_max
    store_key = "openid_max_" + openid.to_s + campaign.id.to_s
    openid_current_count = Rails.cache.read(store_key) || 0
    if openid_current_count >= OpenidMaxCount
      return [false, 'openid_reach_max_count']
    else
      expiry_time = (campaign.deadline.to_time - DateTime.now.to_time).to_i rescue 5*3600*24
      begin
        Rails.cache.write(store_key, openid_current_count + 1, :expires_in => expiry_time.seconds)
      rescue Redis::CommandError
        Rails.cache.write(store_key, openid_current_count + 1, :expires_in => 30.hours)
      end
    end

    # check_ip?
    store_key = visitor_ip.to_s + campaign.id.to_s
    if Rails.cache.read(store_key)
      return [false, 'ip_visit_fre']
    else
      Rails.cache.write(store_key, visit_time, :expires_in => IpTimeout)
    end

    # check_ip_reach_max
    store_key = Date.today.to_s + visitor_ip.to_s
    ip_current_count = Rails.cache.read(store_key) || 0
    if ip_current_count > IpMaxCount
      return [false, 'ip_reach_max_count']
    else
      Rails.cache.write(store_key, ip_current_count + 1, :expires_in => 24.hours)
    end

    kol = Kol.fetch_kol_with_level(campaign_invite.kol_id)
    # check kol's five_click_threshold
    if kol
      store_key =  "five_click_threshold_#{campaign_invite.id}_#{visit_time.min / 5}"
      current_five_click = Rails.cache.read(store_key)  || 0
      if current_five_click >= (kol.five_click_threshold || 20)
        return [false, "exceed_five_click_threshold"]
      else
        Rails.cache.write(store_key, current_five_click + 1, :expires_in => 5.minutes)
      end

      # check kol's max_click depend on kol credits level
      store_key =  "kol_level_#{campaign_invite.id}"
      current_total_click = Rails.cache.read(store_key)  || 0
      if kol.kol_level.present?
        level_threshold  = KolCreditLevels["#{kol.kol_level}"]
      else
        level_threshold = 120
      end
      if current_total_click >= level_threshold
        return [false, "exceed_kol_level_threshold"]
      else
        expiry_time = (campaign.deadline.to_time - DateTime.now.to_time).to_i rescue 5*3600*24
        begin
          Rails.cache.write(store_key,current_total_click + 1, :expires_in => expiry_time.seconds)
        rescue Redis::CommandError
          Rails.cache.write(store_key,current_total_click + 1, :expires_in => 30.hours)
        end
      end
    end

      # check campaign status
    if campaign.status == 'executed'
      #如果是点击类型活动且结束原因不是费用花完, 需要给访问时间小于结束时间的点击算为有效点击
      #return true  redis 会自动增加,但是数据库 已经同步过了 需要手动同步
      if campaign.is_click_type? && campaign.finish_remark.present? && campaign.finish_remark.start_with?('expired') &&
        campaign_invite.status != 'settled' && visit_time <= campaign.actual_deadline_time && campaign.redis_avail_click.value.to_i >= campaign.max_action.to_i
        campaign_invite.increment!(:avail_click)
        campaign_invite.increment!(:total_click)
        return [true, nil]
      end
      return [false, CampaignExecuted]
    end

    if campaign.status != 'executing' || (['cpa', 'click'].include?(campaign.per_budget_type) && campaign.redis_avail_click.value.to_i > campaign.max_action.to_i)
      return [false, CampaignExecuted]
    end

    from_group = (request_uri.include?("groupmessage") ||  request_uri.include?("singlemessage")) ? "from_group" : nil

    return [true,from_group]
  end

  def self.add_click(uuid, visitor_cookies, visitor_ip, visitor_agent, visitor_referer, proxy_ips, request_uri, openid, visit_time, options={})
    options.symbolize_keys!

    info = JSON.parse(Base64.decode64(uuid))   rescue {}
    if info["campaign_action_url_identifier"].present?
      campaign_action_url = CampaignActionUrl.find_by :identifier => info["campaign_action_url_identifier"]
      campaign = campaign_action_url.campaign rescue nil
    else
      campaign = Campaign.find_by :id => info['campaign_id']  rescue nil
    end

    if campaign.is_cpa_type?
      if (options[:step].to_i == 2 or info["step"].to_i == 2)
        campaign_invite_id = Rails.cache.fetch(visitor_cookies + ":cpa_campaign_id:#{campaign.id}")
        campaign_invite = CampaignInvite.find_by :id => campaign_invite_id if campaign_invite_id
      else
        campaign_invite = CampaignInvite.fetch_invite_with_uuid(uuid)
        if campaign.deadline > visit_time
          expiry_time = (campaign.deadline.to_time - DateTime.now.to_time).to_i rescue 5*3600*24
        else
          expiry_time = (visit_time.to_time - DateTime.now.to_time).to_i rescue 5*3600*24
        end
        begin
          Rails.cache.write(visitor_cookies + ":cpa_campaign_id:#{campaign.id}", campaign_invite.id, :expires_in => expiry_time.seconds) if campaign_invite
        rescue Redis::CommandError
          Rails.cache.write(visitor_cookies + ":cpa_campaign_id:#{campaign.id}", campaign_invite.id, :expires_in => 30.hours) if campaign_invite
        end
      end
    else
      campaign_invite = CampaignInvite.fetch_invite_with_uuid(uuid)
    end
    return false if campaign_invite.nil?  ||  campaign.nil?   || ["running", "pending", "rejected"].include?(campaign_invite.try(:status))

    visitor_ip = (proxy_ips.split(",").first rescue nil) || visitor_ip
    campaign_show = CampaignShow.new(:kol_id => info['kol_id'] || campaign_invite.kol_id, :campaign_id => info['campaign_id'] || campaign.id, :visitor_cookie => visitor_cookies,
                                     :visit_time => visit_time, :visitor_ip => visitor_ip, :request_url => request_uri, :visitor_agent => visitor_agent, :visitor_referer => visitor_referer,
                                     :other_options => options.inspect, :proxy_ips => proxy_ips, :openid => openid)
    status, remark = CampaignShow.is_valid?(campaign, campaign_invite, uuid, visitor_cookies, visitor_ip, visitor_agent,visitor_referer, proxy_ips, request_uri, openid, visit_time, options)
    campaign_show.status = status
    campaign_show.remark = remark
    campaign_show.save(:validate => false)
    campaign_invite.add_click(status,remark)
    campaign.add_click(status)
  end

end
