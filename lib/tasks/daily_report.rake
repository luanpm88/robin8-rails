# encoding: utf-8
require 'csv'

namespace :daily_report  do
  
  desc "Send Small-V report to Miranda (or others)"

  task :daily_send => :environment do
    
    ending = DateTime.now.change({ hour: 19 })
    staff_ids = [103985, 71239, 173, 74730, 12275, 61209, 74069]
    
    c = Campaign.where("start_time > ? and start_time < ?", ending - 1.day, ending).where(:status => ['settled', 'executing', 'executed'])
    total_budget = c.sum("budget")
    campaign_count = c.count

    # Calculate the number of new KOLs, and how many of those took a campaign.
    k = Kol.where("created_at > ? and created_at < ?", ending - 1.day, ending)
    kol_count = k.count
    
    # Get number of new clubs
    new_clubs = Club.where("created_at>?", ending-1.day)
    club_count = new_clubs.count
    
    # Get number of new club members (Used to verify how many people the student leader can bring)
    new_club_members = ClubMember.where('created_at>?', ending-1.day)
    cm_count = new_club_members.count
    
    day_leader = (Club.where("created_at>?", ending-1.day).pluck(:kol_id) - staff_ids).uniq
    week_leader = (Club.where("created_at>?", ending-7.day).pluck(:kol_id) - staff_ids).uniq
    all_leader = (Club.pluck(:kol_id) - staff_ids).uniq
    
    day_active_leader = CampaignInvite.where(:kol_id => day_leader).pluck(:kol_id).uniq
    week_active_leader = CampaignInvite.where(:kol_id => week_leader).pluck(:kol_id).uniq
    all_active_leader = CampaignInvite.where(:kol_id => all_leader).pluck(:kol_id).uniq
    
    # Get all member throughs the sponsorship layer
    leaders_and_members = (Club.pluck(:kol_id) + ClubMember.pluck(:kol_id) - staff_ids).uniq
    day_student_invite = CampaignInvite.where(:kol_id => leaders_and_members).where('created_at>?', ending-1.day).uniq
    week_student_invite = CampaignInvite.where(:kol_id => leaders_and_members).where('created_at>?', ending-7.day).uniq
    all_student_invite = CampaignInvite.where(:kol_id => leaders_and_members).uniq

    # Get WAU & DAU
    dau = CampaignInvite.where('created_at>?', ending-1.day).pluck(:kol_id).uniq.count
    wau = CampaignInvite.where('created_at>?', ending-7.day).pluck(:kol_id).uniq.count
    
    ReportMailer.daily_smallV_report(campaign_count, total_budget, kol_count, club_count, cm_count, dau, wau,
        day_leader.count, week_leader.count, all_leader.count,
        day_active_leader.count, week_active_leader.count, all_active_leader.count,
        day_student_invite.count, week_student_invite.count, all_student_invite.count).deliver_now
    
    notifier = Slack::Notifier.new 'https://hooks.slack.com/services/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'
    notifier.ping "Hey guys! 
    We have #{campaign_count} campaigns started in the last 24 hours. The total budget is #{total_budget} RMB. 
    #{kol_count} joined the platform.
    DAU is #{dau}, WAU is #{wau}.
    For sponsorship layer, #{club_count} new leaders joined, while #{cm_count} new members joined.
    "
    # render json: {:status => :ok}
  # rescue
  #   render json: {:status => 'Cant send daily reporting email!'}
    

    puts "\nDaily report is now generated."
  end
  
  task :weekly_send => :environment do
    
    # Set the time to from now to 1 week ago.
    ending = DateTime.now.change({ hour: 19 })
    cs = Campaign.where("start_time > ? and start_time < ?", ending - 1.week, ending).where(:status => ['settled', 'executing', 'executed'])
    
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
    
    ReportMailer.weekly_smallV_report(campaign_count, total_budget, total_consumed, kol_count, real_kol_count).deliver_now
    
    # Send to slack useracquistion channel. 
    notifier = Slack::Notifier.new 'https://hooks.slack.com/services/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'
    notifier.ping "Happy Friday! We have #{campaign_count} campaigns started in the last 7 days. The total budget is #{total_budget.round(1)} RMB. #{total_consumed.round(1)}RMB is consumed."
    notifier.ping "#{kol_count} new KOLs joined. #{real_kol_count} made more than 1 RMB."
    

    puts "\nWeekly report is now generated."
  end
  
  task :monthly_send => :environment do
    
    # Set the time to from now to 1 week ago.
    ending = DateTime.now.change({ hour: 19 })
    cs = Campaign.where("start_time > ? and start_time < ?", 1.month.ago.beginning_of_month, 1.month.ago.end_of_month).where(:status => ['settled', 'executing', 'executed'])
    last_cs = Campaign.where("start_time > ? and start_time < ?", 2.month.ago.beginning_of_month, 2.month.ago.end_of_month).where(:status => ['settled', 'executing', 'executed'])
    
    # Calculate the total budget and campaign
    total_budget = cs.sum("budget")
    campaign_count = cs.count
    budget_increase = (campaign_count - last_cs.count) / last_cs.count.to_f * 100
    total_consumed = 0
    last_total_consumed = 0
    
    # Calculate how much budget is consumed in total.
    cs.each do |c|
      total_consumed = total_consumed + (c.budget - c.remain_budget)
    end
    
    # Calculate consumption from last month.
    last_cs.each do |c|
      last_total_consumed = last_total_consumed + (c.budget - c.remain_budget)
    end
    
    consumed_increase = (total_consumed - last_total_consumed) / last_total_consumed.to_f * 100
    
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
    
    ReportMailer.monthly_smallV_report(campaign_count, total_budget, budget_increase, total_consumed, kol_count, kol_increase, real_kol_count, real_kol_increase).deliver_now
    
    # Send to slack useracquistion channel.
    notifier = Slack::Notifier.new 'https://hooks.slack.com/services/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'
    notifier.ping "First day of the month! We have #{campaign_count} campaigns started in the last 7 days. The total budget is #{total_budget.round(1)} RMB. #{total_consumed.round(1)}RMB is consumed."
    notifier.ping "Count changed by #{budget_increase.round(1)}%. Consumption increased by #{consumed_increase.round(1)}%."
    notifier.ping "#{kol_count} new KOLs joined. A change of #{kol_increase.round(1)}%. #{real_kol_count} made more than 1 RMB. A change of #{real_kol_increase.round(1)}%."
    

    puts "\nMonthly report is now generated."
  end
  
  task :pinyou_send => :environment do
    
    cs = Campaign.where("actual_deadline_time > ? and actual_deadline_time < ?", 3.month.ago.beginning_of_month, 1.month.ago.end_of_month)
    .where(:status => ['settled', 'executed']).where('user_id=?', 2237)
    
    CSV.open("config/data_attrs/pinyou_results.csv","wb") do |csv|
      csv << ["id","截止时间","活动名称","预算","单次消耗","有效点击","状态"]
      cs.all.each_with_index do |cp,index|
            puts "done #{index}"
            csv << [cp.id, cp.actual_deadline_time , cp.name, cp.budget, cp.actual_per_action_budget, cp.avail_click, cp.status, cp.user_id, cp.per_budget_type]
        end
    end
    
    ReportMailer.pinyou_report().deliver_now
    puts "Completed"
  end
end
