class ReportMailer < ApplicationMailer


  # This report will contains the data of small-v campaign count and budget to report daily. 
  def daily_smallV_report(count, budget)
    puts "Prepare for daily email"
    @count = count
    @budget = budget
    mail(:to => 'report@robin8.com', :subject => "【Robin8】Small-V daily report",:from => "Robin8 <no-reply@robin8.com>")
    puts "Daily email sent"
  end
  
  # This report will contains the data of small-v campaign count and budget to report weekly. 
  def weekly_smallV_report(count, budget, total_consumed, kol_count, real_kol_count)
    puts "Prepare for weekly email"
    @count = count
    @budget = budget
    @total_consumed = total_consumed
    @kol_count = kol_count
    @real_kol_count = real_kol_count
    mail(:to => 'report@robin8.com', :subject => "【Robin8】Small-V weekly report",:from => "Robin8 <no-reply@robin8.com>")
    puts "Weekly email sent"
  end
  
  # This report will contains the data of small-v campaign count and budget to report monthly. 
  def monthly_smallV_report(count, budget, budget_increase, total_consumed, kol_count, kol_increase, real_kol_count, real_kol_increase)
    puts "Prepare for monthly email"
    @count = count
    @budget = budget
    @budget_increase = budget_increase
    @total_consumed = total_consumed
    @kol_count = kol_count
    @kol_increase = kol_increase
    @real_kol_count = real_kol_count
    @real_kol_increase = real_kol_increase
    mail(:to => 'report@robin8.com', :subject => "【Robin8】Small-V monthly report",:from => "Robin8 <no-reply@robin8.com>")
    puts "Monthly email sent"
  end
  
end