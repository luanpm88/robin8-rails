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
    if !exist_auto_cal && (Date.today.wday > ScheduleWday || ((Date.today.wday == ScheduleWday) &&  ((Time.now.hour * 60 + Time.now.min) >= (ScheduleHour * 60 + ScheduleMin))))
      auto_history = KolInfluenceValueHistory.new
      attrs = history.attributes
      attrs.delete("id")
      auto_history.attributes = attrs
      auto_history.is_auto = true
      auto_history.save
    end
  end

  #确保每周生成一次 auto=true 然后取最近4条
  def self.get_auto_history(kol_uuid)
    history_scores = []
    KolInfluenceValueHistory.where(:kol_uuid => kol_uuid, :is_auto => true).order("id desc").limit(4).each do |record|
     history_scores << {:date => record.created_at.to_date, :score => record.influence_score}
    end
    history_scores
  end
end
