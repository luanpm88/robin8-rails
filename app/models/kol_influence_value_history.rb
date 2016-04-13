class KolInfluenceValueHistory < ActiveRecord::Base
  ScheduleWday = Rails.application.secrets[:cal_influence][:wday]
  ScheduleHour = Rails.application.secrets[:cal_influence][:hour]
  ScheduleMin = Rails.application.secrets[:cal_influence][:min]
  def self.generate_history(kol_value, is_auto)
    attrs = kol_value.attributes
    attrs.delete("id")
    history = KolInfluenceValueHistory.new(:is_auto => is_auto)
    history.attributes = attrs
    history.save
    exist_auto_cal = KolInfluenceValueHistory.where(:kol_uuid => history.kol_uuid, :is_auto => true).count > 0 ? true : false
    if !exist_auto_cal && (Date.today.wday > ScheduleWday || ((Date.today.wday == ScheduleWday &&  (Time.now.hour * 60 + Time.now.min) >= (ScheduleHour * 60 + ScheduleMin) )
      auto_history = history = KolInfluenceValueHistory.new(:is_auto => is_auto)
    end
  end

end
