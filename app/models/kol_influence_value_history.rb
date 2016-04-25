class KolInfluenceValueHistory < ActiveRecord::Base
  ScheduleWday = Rails.application.secrets[:cal_influence][:wday]
  ScheduleHour = Rails.application.secrets[:cal_influence][:hour]
  ScheduleMin = Rails.application.secrets[:cal_influence][:min]

  def self.generate_history(kol_value, is_auto)
    attrs = kol_value.attributes
    attrs.delete("id")
    attrs.delete("share_times")
    attrs.delete("read_times")
    history = KolInfluenceValueHistory.new(:is_auto => is_auto)
    history.attributes = attrs
    history.save
    exist_auto_cal = KolInfluenceValueHistory.where(:kol_uuid => history.kol_uuid, :is_auto => true).count > 0 ? true : false
    if !exist_auto_cal && (Date.today.wday > ScheduleWday || (Date.today.wday == ScheduleWday &&  (Time.now.hour * 60 + Time.now.min) >= (ScheduleHour * 60 + ScheduleMin)))
      auto_history = KolInfluenceValueHistory.new
      attrs = history.attributes
      attrs.delete("id")
      auto_history.attributes = attrs
      auto_history.is_auto = true
      auto_history.created_at = Time.now - (Date.today.wday - ScheduleWday).days            #生成时间在本周 ScheduleWday
      auto_history.save
    end
  end

  #确保每周生成一次 auto=true 然后取最近6条
  HistorySize = 6
  def self.get_auto_history(kol_uuid)
    history_scores = []
    date = nil
    if Date.today.wday > ScheduleWday || ((Date.today.wday == ScheduleWday) &&  (Time.now.hour * 60 + Time.now.min) >= (ScheduleHour * 60 + ScheduleMin))
      date = Date.today - (Date.today.wday - ScheduleWday).days
    else
      begin_last_week_date = Date.today.last_week
      date = Date.today.last_week +  (ScheduleWday - begin_last_week_date.wday).days
    end
    index = 0
    KolInfluenceValueHistory.where(:kol_uuid => kol_uuid, :is_auto => true).order("id desc").limit(HistorySize).each do |record|
      history_scores << {:date => date - (7 * index).days, :score => record.influence_score}
      index += 1
    end
    (index..HistorySize).each do |i|
      history_scores << {:date => date - (7 * index).days, :score => 0}
      index += 1
    end
    history_scores.sort_by{|t| t[:date]}
  end
end
