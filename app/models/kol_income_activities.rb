# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.

class KolIncomeActivities < ActiveRecord::Base
  
  belongs_to :kol, class_name: "Kol"
#  belongs_to :inviter, inverse_of: :registered_invitations, class_name: "Kol"
#  belongs_to :invitee, inverse_of: :registered_invitation, class_name: "Kol"
  
  def self.job_for_kol_dashboard_income_data testdate=nil
    puts "starts====================================="
    @q    = Kol.joins(:admintags).select("id").where("admintags.tag IS NOT NULL ").ransack()
    @kols_count_all = @q.result.order('id desc').limit(1)
    
    puts @kols_count_all.first.id
    if testdate != nil
      _excute_day = testdate
    else
      _excute_day = Date.today - 1.days
    end
    
    puts @kols_count_all.first.admintags.inspect
    puts @kols_count_all.first.admintags.first.tag
    
    puts "=================="
    
    #puts err
    @kols_count_all.each do |kol|
      cpp_count_income, cpp_count_count = kol.post_or_recruit_campaign_income(_excute_day)
      cpc_sum_income, cpc_sum_count = kol.click_or_action_campaign_income(_excute_day)
      cpt_task_income, cpt_task_count = kol.task_income(_excute_day)
      income =  cpp_count_income + cpc_sum_income +  cpt_task_income
      count = cpp_count_count + cpc_sum_count +  cpt_task_count

      puts income
      puts cpp_count_income
      puts cpc_sum_income
      puts cpt_task_income
      puts count
      puts cpp_count_count
      puts cpc_sum_count
      puts cpt_task_count
      puts "========================"
      puts kol.id
      puts kol.admintags.first.tag

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
        added_at: _excute_day
      }
      
      puts options
      puts "=========ends============"
      #KolIncomeActivities.create(options)

    end
  end
  
end
