# CampaignObserver.observer_campaign_and_kol 343, 54824
module CampaignObserver
  extend self
  MaxTotalClickCount = 100
  MaxValidClickCount = 30
  MaxUniqCookieVisitCount = 20
  MaxUniqUserAgentCount = 40
  MaxMorningVisitCount = 20 # 1点-6点
  IpScoreLess50Count     = 20
  MinAverageSecond       = 60
  MinAverageSecondTotalClickCount = 10


  def notify_operational_staff
    return if Time.now.hour < 8
    base_invites = CampaignInvite.where.not(:screenshot => '').where(:img_status => :pending)
    post_count = base_invites.joins(:campaign).where("per_budget_type='post'").count
    lines = []
    if post_count > 0
      lines << "待审核转发类型的截图有 #{post_count}个"
    end


    campaign_ids = Campaign.where(:status => "executed").map(&:id)
    base_invites = CampaignInvite.where.not(:screenshot => '').where(:img_status => :pending).where(:campaign_id => campaign_ids)
    zero_click_count = base_invites.where(:total_click => 0).where("screenshot is not NULL").order('created_at DESC').count

    if zero_click_count > 0
      lines << "点击量为0 的待审核截图有 #{zero_click_count}个"
    end

    base_invites = CampaignInvite.where.not(:screenshot => '').where(:img_status => :pending)
    suspected_count = base_invites.where(:observer_status => 2).where("screenshot is not NULL").order('created_at DESC').count
    if suspected_count > 0
      lines << "有嫌疑的 待审核截图有 #{suspected_count}个"
    end

    pending_campaigns_count = Campaign.where(status: 'unexecute').realable.where("deadline >?", (Time.now-30.days)).count
    if pending_campaigns_count > 0
      lines << "待审核的活动有 #{pending_campaigns_count}个"
    end

    if lines.present?
      ['18817774892', '15298670933','13764432765','13262752287','15154196577',
       '18551526463', '18321878526','13915128156','15152331980','15298675346',
       '18817774892','15606172163'].each do |tel|
        Emay::SendSms.to tel, lines.join(";\n")
      end
    end
  end

  def observer_campaign_and_kol campaign_id, kol_id
    invalid_reasons = []
    cookie_and_user_agents = {}
    user_agents_count = {}
    morning_visit_count = 0
    ip_scores = {}
    ip_score_less_50_count = 0
    averageClickTime = []
    clicks_group_by_visit_time = {}

    shows = CampaignShow.where(:campaign_id => campaign_id, :kol_id => kol_id).order("created_at asc")

    if shows.where(:status => "1").count > MaxValidClickCount
      invalid_reasons << "有效点击 大于 #{MaxValidClickCount}"
    end

    if shows.count > MaxTotalClickCount
      #invalid_reasons << "总点击量大于#{MaxTotalClickCount} 且有效点击比为: #{shows.where(:status => "1").count * 100.0 / shows.count}% 低于设定的 10% "
      invalid_reasons << "总点击量大于#{MaxTotalClickCount}"
    end

    shows.each do |show|
      cookie_and_user_agents[show.visitor_cookie] ||= {}
      cookie_and_user_agents[show.visitor_cookie][show.visitor_agent] = cookie_and_user_agents[show.visitor_cookie][show.visitor_agent].to_i + 1

      if show.created_at.hour > 0 and  show.created_at.hour < 7
        morning_visit_count += 1
      end

      # Note: Commented out because code related to ip_score_less_50_count is currently not being used
      # ip_score = IpScore.where(:ip => show.visitor_ip).first
      # if ip_score
      #   if ip_score.score <= 50
      #     ip_score_less_50_count += 1
      #   end
      # end

      user_agents_count[show.visitor_agent] = user_agents_count[show.visitor_agent].to_i + 1

      created_at = show.created_at
      if show.created_at.min%5 == 4
        begin_time = Time.new(created_at.year, created_at.month, created_at.day, created_at.hour, (created_at.min/5)*5)

        end_at = created_at + 1.minutes
        end_time = Time.new(end_at.year, end_at.month, end_at.day, end_at.hour, (end_at.min/5)*5)
        clicks_group_by_visit_time[begin_time] ||= []
        clicks_group_by_visit_time[begin_time] << show.created_at

        clicks_group_by_visit_time[end_time] ||= []
        clicks_group_by_visit_time[end_time] << show.created_at
      else
        begin_time = Time.new(created_at.year, created_at.month, created_at.day, created_at.hour, (created_at.min/5)*5)
        clicks_group_by_visit_time[begin_time] ||= []
        clicks_group_by_visit_time[begin_time] << show.created_at
      end
    end

    # cookie_and_user_agents.keys.each do |cookie|
    #   if cookie_and_user_agents[cookie].values.sum > MaxUniqCookieVisitCount
    #     invalid_reasons << "单一cookie 访问了 #{cookie_and_user_agents[cookie].values.sum}了, 超过了#{MaxUniqCookieVisitCount}次的限制"
    #   end
    # end;

    # if morning_visit_count > MaxMorningVisitCount
    #   invalid_reasons << "凌晨1点-6点 访问了 #{morning_visit_count}次, 超过了#{MaxMorningVisitCount}次的限制"
    # end

    # if ip_score_less_50_count > IpScoreLess50Count
    #   invalid_reasons << "访问者ip 小于50分的次数 超过了#{IpScoreLess50Count}次"
    # end

    # if user_agents_count.values.max.to_i >= MaxUniqUserAgentCount
    #   invalid_reasons << "单一user_agent 访问了 #{user_agents_count.values.max}不能超过: #{MaxUniqUserAgentCount}次"
    # end

    clicks_group_by_visit_time.keys.each do |key|
      values = clicks_group_by_visit_time[key]
      # puts values.map(&:to_s)
      if values.count > MinAverageSecondTotalClickCount
        total_space = 0
        values.each_with_index do |item, index|
          if index == 0
            next
          end
          total_space += (values[index] - values[index-1])
        end
        averageClickTime << (total_space/(values.count-1))
      end
    end

    if averageClickTime.size > 10
      cleanAverageClickTime = averageClickTime - averageClickTime.min(3) - averageClickTime.max(3)
      if cleanAverageClickTime.count > 3
        average_time = cleanAverageClickTime.sum/cleanAverageClickTime.count
        mean_deviation = cleanAverageClickTime.map do |number|
          (number - average_time)**2
        end.sum/cleanAverageClickTime.count
        if mean_deviation < 9
          invalid_reasons << "点击时间分布比较均匀, 平均为#{average_time}秒, 存在通过使用程序作弊的嫌疑"
        end
      end
    end
    # puts kol_id, "kol_id"
    # puts campaign_id

    kol = Kol.find_by(:id => kol_id)
    if kol
      campaign_ids = kol.campaigns.where(:status => ['executed','settled']).pluck(:id)
      index = campaign_ids.index(campaign_id)
      indexs = []
      unless index.nil?
        if index > 0 and index < campaign_ids.count-1
          indexs << index - 1
          indexs << index + 1
        elsif index == 0
          indexs << index + 1 if campaign_ids[index + 1]
          indexs << index + 2 if campaign_ids[index + 2]
        elsif index == campaign_ids.count - 1
          indexs << index - 1  if campaign_ids[index - 1]
          indexs << index - 2  if campaign_ids[index - 2]
        end

        campaign_invite = CampaignInvite.where(:campaign_id => campaign_id, :kol_id => kol_id).first
        if indexs.count >= 1 and campaign_invite.total_click > 30
          now_cookies = shows.map(&:visitor_cookie)
          indexs.each do |index|
            overlap = (CampaignShow.where(:kol_id => kol_id, :campaign_id => campaign_ids[index]).map(&:visitor_cookie) & now_cookies).count*1.0/now_cookies.count
            if overlap > 0.3
              invalid_reasons << "存在固定的人(#{(now_cookies.count*overlap).to_i} 人)帮该用户点击(猜测可能是有一个群, 相互点击), 和campaign_id: #{campaign_ids[index]} 的重合度是: #{(overlap*100).to_i}%, 大于我们设置的 30% 重合阈值"
              campaign_invite.permanent_reject("系统检测到有作弊嫌疑")
            end
          end
        end
      end
    end

    invalid_reasons
  end

  def observer_text
    texts = []
    texts << "总点击量不能超过: #{MaxTotalClickCount}次, 有效点击比 小于 10%"
    texts << "有效点击量不能超过: #{MaxValidClickCount}次"
    # texts << "单一cookie 不能超过:  #{MaxUniqCookieVisitCount}次"
    # texts << "凌晨1点-6点 访问量, 不能超过 #{MaxMorningVisitCount}次"
    # texts << "访问者ip 不能超过#{IpScoreLess50Count}次"
    # texts << "单一user_agent 不能超过: #{MaxUniqUserAgentCount}次"
    texts  << "统计点击时间分布情况, 判断是否是通过爬虫点击"
    #texts  << "该用户最近接过的 3个campaign 点击的cookies 重合度, 来判断这个用户 是否会有固定的人群 帮他点击"
    texts
  end
end
