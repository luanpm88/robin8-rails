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

set :output, {
  :error => File.join(path, "log", "cron_error.log"),
  :standard => File.join(path, "log", "cron.log")
}

every 12.hours do
  runner "UserProduct.process_recurring_invoice"
end

every 1.days do
  runner "UserProduct.batch_suspend"
end

# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

# updating sitemap
every 1.day, :at => '5:00 am' do
  rake "-s sitemap:refresh"
end

every 5.minutes do
  rake 'alert:notify_users_via_email'
end

every 3.hours do
  rake 'alert:notify_users_via_text'
end

every 1.hour do
  rake 'mailgun:shoot["rapidly"]'
end
