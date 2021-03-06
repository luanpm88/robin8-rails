class CampaignShow < ActiveRecord::Base
  include Concerns::CampaignShowForCpi
  CookieTimeout = Rails.env.production? ? 45.minutes : 5.seconds
  OpenidMaxCount = Rails.env.production? ? 1 : 10
  IpTimeout = Rails.env.production? ? 30.seconds : 5.seconds
  IpMaxCount = Rails.env.production? ? 20 : 40
  CampaignExecuted = 'campaign_had_executed'

  REMARKS = {
    over_max_click: '超过最大点击限制',
    wechat_crawler: 'ip重叠度高，视为作弊',
    had_no_openid: '不是有效的微信账号',
    visitor_agent_is_invalid: '无效的浏览器点击',
    visitor_referer_exist: '引用页已存在',
    is_first_step_of_cpa_campaign: '第一步cpa活动',
    the_first_step_not_exist_of_cpa_campaign: 'cpa活动第一步不存在',
    the_two_step_has_not_openid_of_cpa_campaign: 'cpa活动第二步无openid',
    openid_reach_max_count: '同一用户的重复点击',
    ip_visit_fre: '同一ip的重复点击',
    ip_reach_max_count: '24小时内，同ip用户点击超过20个',
    exceed_five_click_threshold: '超过该用户可获得的最大点击',
    exceed_kol_level_threshold: '超过kol等级点击限制',
    campaign_had_executed: '活动结束后获得的点击'
  }

  belongs_to :campaign
  belongs_to :kol
  scope :valid, ->{ where(:status => 1) }
  scope :by_date, ->(datetime) { where("created_at >= '#{datetime}' and created_at < '#{datetime + 1.day}'") }
  scope :today, -> {where(:created_at => Time.now.beginning_of_day..Time.now.end_of_day)}
  scope :invite_need_settle, ->(campaign_id,kol_id,settle_deadline) {where("created_at <= '#{settle_deadline}'").where("transaction_id is null").where(:status => 1, :campaign_id => campaign_id, :kol_id => kol_id)}

  def remark_CH
    REMARKS[remark.try(:to_sym)]
  end

  def status_CN
    {'1' => '有效', '0' => '无效'}[status]
  end

  # 检查 campaign status
  def self.is_valid?(campaign, campaign_invite, uuid, visitor_cookies, visitor_ip, visitor_agent, visitor_referer, proxy_ips, request_uri, openid, visit_time, options={})
    return [false, 'over_max_click'] if campaign.redis_avail_click.value.to_i >= campaign.max_action.to_i
    
    visit_time = visit_time.to_time

    if visitor_ip.start_with?("101.226.103.6") || visitor_ip.start_with?("101.226.103.7")
      return [false, 'wechat_crawler']
    end

    if campaign.wechat_auth_type != 'no' && openid.blank?  && options[:step] != 2
      return [false, 'had_no_openid']
    end

    # check_useragent? && visitor_referer
    # return [false, 'visitor_agent_is_invalid'] if visitor_agent.blank? || !visitor_agent.include?("MicroMessenger")
    return [false, 'visitor_agent_is_invalid'] unless visitor_agent.include?("MicroMessenger")
    return [false, 'visitor_referer_exist']    if visitor_referer.present? and !campaign.is_cpa_type?

    # openid_reach_max
    store_key = "openid_max_" + openid.to_s + campaign.id.to_s

    openid_current_count = $redis.get(store_key).to_i

    if openid_current_count >= OpenidMaxCount
      return [false, 'openid_reach_max_count']
    else
      expiry_time = (campaign.deadline.to_time - DateTime.now.to_time).to_i
      expiry_time = 5*3600*24 if expiry_time < 1
      $redis.setex(store_key, expiry_time, openid_current_count.succ)
    end

    # check_ip?
    store_key = visitor_ip.to_s + campaign.id.to_s
    if $redis.get(store_key)
      return [false, 'ip_visit_fre']
    else
      $redis.setex(store_key, IpTimeout, visit_time)
    end

    # check_ip_reach_max
    store_key = Date.today.to_s + visitor_ip.to_s
    ip_current_count = $redis.get(store_key).to_i
    if ip_current_count > IpMaxCount
      return [false, 'ip_reach_max_count']
    else
      $redis.setex(store_key, 24.hours, ip_current_count.succ)
    end

    kol = Kol.fetch_kol_with_level(campaign_invite.kol_id)
    # check kol's five_click_threshold
    if kol
      store_key =  "five_click_threshold_#{campaign_invite.id}_#{visit_time.min / 5}"
      current_five_click = $redis.get(store_key).to_i
      # if current_five_click >= (kol.five_click_threshold || 20)
      # campaign.is_limit_click_count 是否放开朋友圈的点击数，只放开kol的等级限制
      if campaign.is_limit_click_count && current_five_click >= (kol.five_click_threshold || 20)
        return [false, "exceed_five_click_threshold"]
      else
        $redis.setex(store_key, 5.minutes, current_five_click.succ)
      end

      # check kol's max_click depend on kol credits level
      store_key =  "kol_level_#{campaign_invite.id}"
      current_total_click = $redis.get(store_key).to_i

      level_threshold = kol.kol_level ? Rails.application.secrets[:kol_levels][kol.kol_level.to_sym] : 120
      # if current_total_click >= level_threshold
      # campaign.is_limit_click_count 是否放开朋友圈的点击数，只放开kol的等级限制
      if campaign.is_limit_click_count && current_total_click >= level_threshold
        return [false, "exceed_kol_level_threshold"]
      else
        expiry_time = (campaign.deadline.to_time - DateTime.now.to_time).to_i rescue 5*3600*24
        $redis.setex(store_key, expiry_time, current_total_click.succ)
      end
    end

      # check campaign status
    if campaign.status == 'executed'
      #如果是点击类型活动且结束原因不是费用花完, 需要给访问时间小于结束时间的点击算为有效点击
      #return true  redis 会自动增加,但是数据库 已经同步过了 需要手动同步
      if campaign.is_click_type? && campaign.finish_remark.present? && campaign.finish_remark.start_with?('expired') &&
        campaign_invite.status != 'settled' && visit_time <= campaign.actual_deadline_time && campaign.redis_avail_click.value.to_i < campaign.max_action.to_i
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

    info = JSON.parse(Base64.decode64(uuid)) rescue {}

    campaign =  if info["campaign_action_url_identifier"]
                  CampaignActionUrl.find_by(identifier: info["campaign_action_url_identifier"]).try(:campaign)
                else
                  Campaign.find_by(id: info['campaign_id'])
                end

    return false unless campaign

    campaign_invite = CampaignInvite.fetch_invite_with_uuid(uuid)

    return false if ["running", "pending", "rejected", nil].include?(campaign_invite.try(:status))

    visitor_ip = (proxy_ips.split(",").first rescue nil) || visitor_ip

    campaign_show = CampaignShow.new(
                      kol_id:           campaign_invite.kol_id,
                      campaign_id:      campaign.id,
                      visitor_cookie:   visitor_cookies,
                      visit_time:       visit_time,
                      visitor_ip:       visitor_ip,
                      request_url:      request_uri,
                      visitor_agent:    visitor_agent,
                      visitor_referer:  visitor_referer,
                      other_options:    options.inspect,
                      proxy_ips:        proxy_ips,
                      openid:           openid
                    )
    status, remark = CampaignShow.is_valid?(campaign, campaign_invite, uuid, visitor_cookies, visitor_ip, visitor_agent,visitor_referer, proxy_ips, request_uri, openid, visit_time, options)
    campaign_show.status = status
    campaign_show.remark = remark
    campaign_show.save(validate: false)
    campaign_invite.add_click(status,remark)
    campaign.add_click(status)
  end

end
