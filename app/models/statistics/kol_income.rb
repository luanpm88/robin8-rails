class Statistics::KolIncome < ActiveRecord::Base
  belongs_to :kol, class_name: "Kol"


  scope :admintag, ->(admintag) { includes(:kol).joins(:kol).where("admintag=? ", admintag) }
  # scope :time_range, ->(t1, t2)
  
  def self.job_for_kol_dashboard_income_data(admintag='geometry', _excute_day=1.days.ago) 
    Kol.joins(:admintags).where("admintags.tag=? ", admintag).each do |kol|
      cpp_count_income, cpp_count_count = kol.post_or_recruit_campaign_income(_excute_day)
      cpc_sum_income, cpc_sum_count     = kol.click_or_action_campaign_income(_excute_day)
      cpt_task_income, cpt_task_count   = kol.task_income(_excute_day)
      inv_frd_income, inv_frd_count     = kol.inv_frd_income(_excute_day)
      
      income = cpp_count_income + cpc_sum_income + cpt_task_income + inv_frd_income
      count  = cpp_count_count + cpc_sum_count + cpt_task_count + inv_frd_count
      
      if income > 0 || count > 0
        self.create(
          kol_id:             kol.id, 
          admintag:           kol.admintags.first.tag, 
          cpc_income:         cpc_sum_income, 
          cpc_count:          cpc_sum_count, 
          cpp_income:         cpp_count_income, 
          cpp_count:          cpp_count_count, 
          cpt_income:         cpt_task_income, 
          cpt_count:          cpt_task_count,
          invite_frd_income:  inv_frd_income,
          invite_frd_count:   inv_frd_count,
          day_of_income:      income,
          day_of_count:       count,
          action_at:          _excute_day
        )
      end
    end
  end
  
  def self.find_incomes admintag, _start_date, _end_date
    types = ['reg','cpc','inc']
    result = {}
    
    types.each do |type|
      rank = 1
      data = self.get_income(admintag, _start_date, _end_date, type)
      
      tmp = {}
      data.each do |item|
        tmp["top#{rank}"] = {
          avatar: item.avatar_url,
          name: item.name,
          price: item.income,
        }
        rank += 1
      end
      result[type] = tmp
    end
    result
    
  end
  
  def self.get_income admintag, _start_date, _end_date, type
    cur_type_income = ""
    cur_type_count = ""
    case type
    when "reg"
      cur_type_income = "invite_frd_income"
      cur_type_count = "invite_frd_count"
    when "cpc"
      cur_type_income = "cpc_income"
      cur_type_count = "cpc_count"
    when "inc"
      cur_type_income = "day_of_income"
      cur_type_count = "day_of_count"
    end
    self.find_by_sql("
    SELECT kols.name, kols.avatar_url, statistics_kol_incomes.kol_id,
    statistics_kol_incomes.id, statistics_kol_incomes.invite_frd_income,
    sum(statistics_kol_incomes.#{cur_type_income}) as income,
    sum(statistics_kol_incomes.#{cur_type_count}) as count 
    FROM statistics_kol_incomes
    INNER JOIN `kols` ON `kols`.`id` = `statistics_kol_incomes`.`kol_id`
    where admintag = '#{admintag}' 
    AND #{cur_type_income} is not null
    AND statistics_kol_incomes.action_at BETWEEN '" + _start_date.to_s + "' 
    AND '" + _end_date.to_s + "'
    group by kol_id order by income DESC LIMIT 3
    ")
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
