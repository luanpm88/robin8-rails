class Statistics::KolIncome < ActiveRecord::Base
  belongs_to :kol, class_name: "Kol"
  
  def self.job_for_kol_dashboard_income_data testdate=nil
    
    
    # FIXME for all admintags 給全部的 admintag 跑一次
    #@q    = Kol.joins(:admintags).select("id").where("admintags.tag IS NOT NULL ").ransack()
    
    # FIXME for all admintags 只跑geometry的
    admintag = Admintag.find_by_tag "geometry"
    @kols    = Kol.joins(:admintags).where("admintags.tag=? ", admintag.tag).order('id asc')
    
    if testdate != nil
      _excute_day = testdate
    else
      _excute_day = 1.days.ago
    end
    
    @kols.each do |kol|
      cpp_count_income, cpp_count_count = kol.post_or_recruit_campaign_income(_excute_day)
      cpc_sum_income, cpc_sum_count = kol.click_or_action_campaign_income(_excute_day)
      cpt_task_income, cpt_task_count = kol.task_income(_excute_day)
      income =  cpp_count_income + cpc_sum_income +  cpt_task_income
      count = cpp_count_count + cpc_sum_count +  cpt_task_count

      options = { kol_id: kol.id, 
        admintag: kol.admintags.first.tag, 
        cpc_income: cpc_sum_income, 
        cpc_count: cpc_sum_count, 
        cpp_income: cpp_count_income, 
        cpp_count: cpp_count_count, 
        cpt_income: cpt_task_income, 
        cpt_count: cpt_task_count,
        day_of_income: income,
        day_of_count: count,
        action_at: _excute_day
      }
      # 沒收益不會存入
      if income > 0 or count > 0
        self.create(options)
      end
    end
  end
end
