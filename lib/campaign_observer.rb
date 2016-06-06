# CampaignObserver.observer_campaign_and_kol 343, 54824
module CampaignObserver
  extend self
  MaxTotalClickCount = 100
  MaxValidClickCount = 50
  MaxUniqCookieVisitCount = 20
  MaxUniqUserAgentCount = 40
  MaxMorningVisitCount = 20 # 1点-6点
  IpScoreLess50Count     = 20
  MinAverageSecond       = 60
  MinAverageSecondTotalClickCount = 10


  def observer_campaign_and_kol campaign_id, kol_id
    campaign = Campaign.where(:id => campaign_id).first
    invalid_reasons = []
    cookie_and_user_agents = {}
    user_agents_count = {}
    morning_visit_count = 0
    ip_scores = {}
    ip_score_less_50_count = 0
    averageClickTime = []
    clicks_group_by_visit_time = {}

    shows = CampaignShow.where(:campaign_id => campaign_id, :kol_id => kol_id).order("created_at asc")

    if shows.count > MaxTotalClickCount
      invalid_reasons << "总点击量大于#{MaxTotalClickCount}"
    end

    if shows.where(:status => "1").count > MaxValidClickCount
      invalid_reasons << "有效点击量大于#{MaxValidClickCount}"
    end

    shows.each do |show|
      cookie_and_user_agents[show.visitor_cookie] ||= {}
      cookie_and_user_agents[show.visitor_cookie][show.visitor_agent] = cookie_and_user_agents[show.visitor_cookie][show.visitor_agent].to_i + 1

      if show.created_at.hour > 0 and  show.created_at.hour < 7
        morning_visit_count += 1
      end

      ip_score = IpScore.where(:ip => show.visitor_ip).first
      if ip_score
        if ip_score.score <= 50
          ip_score_less_50_count += 1
        end
      end

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

    cookie_and_user_agents.keys.each do |cookie|
      if cookie_and_user_agents[cookie].values.sum > MaxUniqCookieVisitCount
        invalid_reasons << "单一cookie 访问了 #{cookie_and_user_agents[cookie].values.sum}了, 超过了#{MaxUniqCookieVisitCount}次的限制"
      end
    end;

    if morning_visit_count > MaxMorningVisitCount
      invalid_reasons << "凌晨1点-6点 访问了 #{morning_visit_count}次, 超过了#{MaxMorningVisitCount}次的限制"
    end

    if ip_score_less_50_count > IpScoreLess50Count
      invalid_reasons << "访问者ip 小于50分的次数 超过了#{IpScoreLess50Count}次"
    end

    if user_agents_count.values.max.to_i >= MaxUniqUserAgentCount
      invalid_reasons << "单一user_agent 访问了 #{user_agents_count.values.max}不能超过: #{MaxUniqUserAgentCount}次"
    end

    clicks_group_by_visit_time.keys.each do |key|
      values = clicks_group_by_visit_time[key]
      puts values.map(&:to_s)
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
    end;nil
    
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
    puts kol_id, "kol_id"
    puts campaign_id
    
    kol = Kol.find_by(:id => kol_id)
    if kol
      campaign_ids = kol.campaigns.where(:status => ['executed','settled']).map(&:id)
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

        if indexs.count >= 1 and CampaignInvite.where(:campaign_id => campaign_id, :kol_id => kol_id).first.total_click > 30
          now_cookies = shows.map(&:visitor_cookie)
          indexs.each do |index|
            overlap = (CampaignShow.where(:kol_id => kol_id, :campaign_id => campaign_ids[index]).map(&:visitor_cookie) & now_cookies).count*1.0/now_cookies.count
            if overlap > 0.3
              invalid_reasons << "存在固定的人(#{(now_cookies.count*overlap).to_i} 人)帮该用户点击(猜测可能是有一个群, 相互点击), 和campaign_id: #{campaign_ids[index]} 的重合度是: #{(overlap*100).to_i}%, 大于我们设置的 30% 重合阈值"
            end
          end
        end
      end
    end

    invalid_reasons
  end

  def observer_text
    texts = []
    texts << "总点击量不能超过: #{MaxTotalClickCount}次"
    texts << "有效点击量不能超过: #{MaxValidClickCount}次"
    texts << "单一cookie 不能超过:  #{MaxUniqCookieVisitCount}次"
    texts << "凌晨1点-6点 访问量, 不能超过 #{MaxMorningVisitCount}次"
    texts << "访问者ip 不能超过#{IpScoreLess50Count}次"
    texts << "单一user_agent 不能超过: #{MaxUniqUserAgentCount}次"
    texts  << "统计点击时间分布情况, 判断是否是通过爬虫点击"
    texts  << "该用户最近接过的 3个campaign 点击的cookies 重合度, 来判断这个用户 是否会有固定的人群 帮他点击"
    texts
  end
end