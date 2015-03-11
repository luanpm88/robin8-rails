# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
every '*/1 * * * *' do
  runner "Subscription.process_initial_invoice"
end

every 12.hours do
  runner "Subscription.process_recurring_invoice"
end

every 1.days do
  runner "Subscription.batch_suspend"
end

# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
