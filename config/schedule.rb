# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every '*/1 * * * *' do
#   runner "Subscription.process_initial_invoice"
# end

env :PATH, ENV['PATH']

set :output, {
  :error => File.join(path, "log", "cron_error.log"),
  :standard => File.join(path, "log", "cron.log")
}

# Learn more: http://github.com/javan/whenever
every 1.day, :at => '0:10 am' do
  command "backup perform --trigger robin8_backup_qiniu"
end

# updating sitemap
# every 1.day, :at => '5:00 am' do
#   rake "-s sitemap:refresh"
# end

# Syncs the database into QA and STAGING every night
=begin
every 1.day, :at => '12:01 am', roles: [:db_syncer] do
  rake "db:export_prod"
end

every 1.day, :at => '2:00 am', roles: [:db_syncer] do
  rake "db:import_to_staging"
end
=end

every 1.day, :at => '12:00 am' do
  command "backup perform --trigger robin8_backup_local"
end

every 1.day, :at => '12:00 pm' do
  command "backup perform --trigger robin8_backup_local"
end

every 1.day, :at => '2:30 am' do
  rake 'influence_score:refresh'
end

#keep with secret
# every :tuesday, :at => '0:10 am' do
#   runner "KolInfluenceValue.schedule_cal_influence"
# end

#cpc截图定时自动审核通过
every 1.day, :at => '0:15 am' do
  runner "CampaignInvite.auto_change_multi_img_status" , :environment => 'production'
end

#cpp截图定时自动审核通过
every 1.day, :at => '0:45 am' do
  runner "CampaignInvite.auto_change_cpp_multi_img_status" , :environment => 'production'
end

#合作平台截图自动通过
every 1.day, :at => '1:15 am' do
  runner "CampaignInvite.auto_channel_kol_multi_img_status" , :environment => 'production'
end

# 定时处理geometry 截图审核
every 1.day, :at => '0:05 am' do
  runner "CampaignInvite.schedule_day_settle", :environment => 'production'
end

every 1.day, :at => '0:30 am' do
  runner "CampaignInvite.remove_old_invitations", :environment => 'production'
end

every 5.minutes do
  runner "CampaignInvite.schedule_day_settle", :environment => 'staging'
end

every 1.day, :at => '0:05 am' do
  runner "CampaignInvite.schedule_day_settle", :environment => 'qa'
end

every 1.day, :at => '17:01 pm' do
  runner "CampaignObserver.notify_operational_staff", :environment => 'production'
end

every 1.day, :at => '1:00 am' do
  rake "kol_amount_statistic:export"
end

every 1.day, :at => '0:30 am', :roles => [:prod_server] do
  rake "schedule:sidekiq_restart"
end

# every 12.hours do
#   runner "KolStatus.schedule_update_status"
# end
# every 1.day, :at => '11:00 am' do
#   runner "PushMessage.push_campaign_message"
# end

every 1.day, :at => '20:30 pm' do
  runner "PushMessage.push_campaign_message"
end

#================cps===================
every 10.minutes do
  runner "Jd::SyncOrder.schedule_sync"
  runner "Jd::SyncCommission.schedule_sync"
end

every 1.hours do
  runner "Jd::SyncOrder.schedule_sync"
  runner "Jd::SyncCommission.schedule_sync"
end

every 1.day, :at => '0:40 am' do
  runner "Jd::SyncOrder.schedule_sync_history(10)"
  runner "Jd::SyncCommission.schedule_sync_history(10)"
  runner "Jd::Settle.schedule_settle"
  runner "Jd::OffShelf.go"
end

# auto check and  start unicorn when unicorn is down
#Notice :slave server not exec crontab(no join whenever role),admin need manual exec(need delete others task)
#        or link from shared directory, not from github
every 1.minutes do
  command "-----exec check unicorn"
  command "/home/deployer/apps/robin8/current/config/check_unicorn.sh"
end

# Auto report system
# This one will report each day at 7pm to Miranda about the small-V campaings from the last 24 hoours

every 1.day, :at => '7:00 pm' do
  rake "daily_report:daily_send", :environment => 'production'
end

every :friday, :at => '7:05pm' do
  rake "daily_report:weekly_send", :environment => 'production'
end

every '10 19 1 * *' do
  rake "daily_report:monthly_send", :environment => 'production'
end

every '00 10 1 1 *' do
  rake "daily_report:pinyou_send", :environment => 'production'
end

every '00 10 1 4 *' do
  rake "daily_report:pinyou_send", :environment => 'production'
end

every '00 10 1 7 *' do
  rake "daily_report:pinyou_send", :environment => 'production'
end

every '00 10 1 10 *' do
  rake "daily_report:pinyou_send", :environment => 'production'
end

every :thursday , :at => '12:05 pm' do
  runner "Message.thursday_push" , :environment => 'production'
end
