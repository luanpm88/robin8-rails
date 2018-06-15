class Statistics::KolIncome < ActiveRecord::Base
  belongs_to :kol, class_name: "Kol"


  scope :admintag, ->(admintag) { includes(:kol).joins(:kol).where("admintag=? ", admintag) }
  scope :recent, ->(_start,_end){ where(action_at: _start.beginning_of_day.._end.end_of_day) }
  
  def self.job_for_kol_dashboard_income_data(admintag='geometry', _excute_day=1.days.ago) 
    Kol.joins(:admintags).where("admintags.tag=? ", admintag).each do |kol|
      cpp_count_income, cpp_count_count = kol.post_or_recruit_campaign_income(_excute_day)
      cpc_sum_income, cpc_sum_count     = kol.click_or_action_campaign_income(_excute_day)
      cpt_task_income, cpt_task_count   = kol.task_income(_excute_day)

      income = cpp_count_income + cpc_sum_income + cpt_task_income
      count  = cpp_count_count + cpc_sum_count + cpt_task_count

      if income > 0 || count > 0
        self.create(
          kol_id:         kol.id, 
          admintag:       kol.admintags.first.tag, 
          cpc_income:     cpc_sum_income, 
          cpc_count:      cpc_sum_count, 
          cpp_income:     cpp_count_income, 
          cpp_count:      cpp_count_count, 
          cpt_income:     cpt_task_income, 
          cpt_count:      cpt_task_count,
          day_of_income:  income,
          day_of_count:   count,
          action_at:      _excute_day
        )
      end
    end
  end

  def to_hash
    {
      day_of_income:     day_of_income,
      kol_name:          kol.name,
      avatar_url:        kol.avatar_url
    }
  end
  
  def self.job_for_init_data admintag, _start_date, _end_date
    if _start_date.empty? or _end_date.empty?
      puts "start or end date missing" and return
    end
    sd = Date.parse _start_date
    ed = Date.parse _end_date
    sd.upto(ed) { |date|
      self.job_for_kol_dashboard_income_data(admintag, date)
    }
    
  end
end