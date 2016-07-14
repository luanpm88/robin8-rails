class KolInfluenceValueHistory < ActiveRecord::Base
  ScheduleWday = Rails.application.secrets[:cal_influence][:wday]
  ScheduleHour = Rails.application.secrets[:cal_influence][:hour]
  ScheduleMin = Rails.application.secrets[:cal_influence][:min]

  def self.generate_history(kol_value, is_auto = false)
    attrs = kol_value.attributes
    attrs.delete("id")
    attrs.delete("share_times")
    attrs.delete("read_times")
    attrs.delete("created_at")
    attrs.delete("updated_at")
    history = KolInfluenceValueHistory.new(:is_auto => is_auto)
    history.attributes = attrs
    history.save
    #不需要生成历史了 因为现在每天的测评都会放上去
    # exist_auto_cal = KolInfluenceValueHistory.where(:kol_uuid => history.kol_uuid, :is_auto => true).count > 0 ? true : false
    # if !exist_auto_cal && (Date.today.wday > ScheduleWday || (Date.today.wday == ScheduleWday &&  (Time.now.hour * 60 + Time.now.min) >= (ScheduleHour * 60 + ScheduleMin)))
    #   auto_history = KolInfluenceValueHistory.new
    #   attrs = history.attributes
    #   attrs.delete("id")
    #   attrs.delete("updated_at")
    #   auto_history.attributes = attrs
    #   auto_history.is_auto = true
    #   auto_history.created_at = Time.now - (Date.today.wday - ScheduleWday).days            #生成时间在本周 ScheduleWday
    #   auto_history.save
    # end
  end

  #确保每周生成一次 auto=true 然后取最近6条
  HistorySize = 6
  def self.get_auto_history(kol_uuid, kol_id)
    history_scores = []
    index = 0
    oldest_cal_date = Date.today
    if kol_id
      history =  KolInfluenceValueHistory.select("max(influence_score) as influence_score, created_at").where(:kol_id => kol_id).group("DATE(created_at)").order("id desc").limit(HistorySize)
    else
      history =  KolInfluenceValueHistory.select("max(influence_score)as influence_score, created_at").where(:kol_uuid => kol_uuid).group("DATE(created_at)").order("id desc").limit(HistorySize)
    end
    history.each do |record|
      history_scores << {:date => record.created_at.to_date, :score => record.influence_score}
      oldest_cal_date = record.created_at.to_date
      index += 1
    end
    i = 0
    while i < HistorySize - index
      history_scores << {:date => oldest_cal_date - (7 * (i + 1)).days, :score => 0}
      i += 1
    end
    history_scores.sort_by{|t| t[:date]}
  end
end
