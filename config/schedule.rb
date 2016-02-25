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
every 1.day, :at => '5:00 am' do
  rake "-s sitemap:refresh"
end

every 1.day, :at => '12:00 am' do
  command "backup perform --trigger robin8_backup_local"
end

every 1.day, :at => '12:00 pm' do
  command "backup perform --trigger robin8_backup_local"
end
