# encoding: utf-8

namespace :daily_report  do
  
  desc "Send Small-V report to Miranda (or others)"

  task :daily_send => :environment do
    
    ending = DateTime.now.change({ hour: 19 })
    c = Campaign.where("start_time > ? and start_time < ?", ending - 1.day, ending)
    total_budget = c.sum("budget")
    campaign_count = c.count
    
    ReportMailer.daily_smallV_report(campaign_count, total_budget).deliver
    # render json: {:status => :ok}
  # rescue
  #   render json: {:status => 'Cant send daily reporting email!'}
    

    puts "\nDaily report is now generated."
  end
  
  task :weekly_send => :environment do
    
    # Set the time to from now to 1 week ago.
    ending = DateTime.now.change({ hour: 19 })
    cs = Campaign.where("start_time > ? and start_time < ?", ending - 1.week, ending)
    
    # Calculate the total budget and campaign
    total_budget = cs.sum("budget")
    campaign_count = cs.count
    total_consumed = 0
    
    # Calculate how much budget is consumed in total.
    cs.each do |c|
      total_consumed = total_consumed + (c.budget - c.remain_budget)
    end
    
    # Calculate the number of new KOLs, and how many of those took a campaign.
    k = Kol.where("created_at > ? and created_at < ?", ending - 1.week, ending)
    kol_count = k.count
    
    # If the historical_income is more than 1, it is likely that the user did something other that just check in.
    real_kol = k.where("historical_income > ?", 1)
    real_kol_count = real_kol.count
    
    ReportMailer.weekly_smallV_report(campaign_count, total_budget, total_consumed, kol_count, real_kol_count).deliver
    

    puts "\nWeekly report is now generated."
  end
  
  task :monthly_send => :environment do
    
    # Set the time to from now to 1 week ago.
    ending = DateTime.now.change({ hour: 19 })
    cs = Campaign.where("start_time > ? and start_time < ?", 1.month.ago.beginning_of_month, 1.month.ago.end_of_month)
    last_cs = Campaign.where("start_time > ? and start_time < ?", 2.month.ago.beginning_of_month, 2.month.ago.end_of_month)
    
    # Calculate the total budget and campaign
    total_budget = cs.sum("budget")
    campaign_count = cs.count
    budget_increase = (campaign_count - last_cs.count) / last_cs.count.to_f * 100
    total_consumed = 0
    
    # Calculate how much budget is consumed in total.
    cs.each do |c|
      total_consumed = total_consumed + (c.budget - c.remain_budget)
    end
    
    # Calculate the number of new KOLs, and how many of those took a campaign.
    k = Kol.where("created_at > ? and created_at < ?", 1.month.ago.beginning_of_month, 1.month.ago.end_of_month)
    last_k = Kol.where("created_at > ? and created_at < ?", 2.month.ago.beginning_of_month, 2.month.ago.end_of_month)
    kol_count = k.count
    kol_increase = (kol_count - last_k.count) / last_k.count.to_f * 100
    
    # If the historical_income is more than 1, it is likely that the user did something other that just check in.
    real_kol = k.where("historical_income > ?", 1)
    last_real_kol = last_k.where("historical_income > ?", 1)
    real_kol_count = real_kol.count
    real_kol_increase = (real_kol_count - last_real_kol.count)/ last_real_kol.count.to_f * 100
    
    ReportMailer.monthly_smallV_report(campaign_count, total_budget, budget_increase, total_consumed, kol_count, kol_increase, real_kol_count, real_kol_increase).deliver
    

    puts "\nMonthly report is now generated."
  end
  
end
