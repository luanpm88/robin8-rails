class ReportMailer < ApplicationMailer


  # This report will contains the data of small-v campaign count and budget to report daily. 
  def daily_smallV_report(count, budget, kol_count, club_count, cm_count, dau, wau, day_leader, week_leader, all_leader, \
      day_active_leader, week_active_leader, all_active_leader, day_invite, week_invite, all_invite)
    puts "Prepare for daily email"
    @count = count
    @budget = budget
    @dau = dau
    @wau = wau
    @clubs = club_count
    @members = cm_count
    @kol = kol_count
    @day_leader = day_leader
    @week_leader = week_leader
    @all_leader = all_leader
    @day_active_leader = day_active_leader
    @week_active_leader = week_active_leader
    @all_active_leader = all_active_leader
    @day_invite = day_invite
    @week_invite = week_invite
    @all_invite = all_invite
    mail(:to => 'report@robin8.com', :subject => "【Robin8】Small-V daily report",:from => "Robin8 <system@robin8.com>")
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
    mail(:to => 'report@robin8.com', :subject => "【Robin8】Small-V weekly report",:from => "Robin8 <system@robin8.com>")
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
    mail(:to => 'monthly_report@robin8.com', :subject => "【Robin8】Small-V monthly report",:from => "Robin8 <system@robin8.com>")
    puts "Monthly email sent"
  end
  
  # Sends Crystal a report of Pinyou every 3 months.
  def pinyou_report()
    puts "Prepare for Pinyou report"
    attachments['pinyou_report.csv'] = File.read('config/data_attrs/pinyou_results.csv')
    mail(:to => 'cxie@robin8.com', :subject => "【Robin8】Pinyou report",:from => "Robin8 <system@robin8.com>")
    File.delete('config/data_attrs/pinyou_results.csv')
  end
  
end