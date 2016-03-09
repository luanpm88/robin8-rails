
formatter = Proc.new{ |severity, time, progname, msg|
  formatted_severity = sprintf("%-5s", severity.to_s)
  formatted_time = time.strftime("%Y-%m-%d %H:%M:%S")
  "[#{formatted_severity} #{formatted_time} #{$$}] #{msg.to_s.strip}\n"
}
MultiLogger.add_logger('transaction', formatter: formatter)
MultiLogger.add_logger('sidekiq', formatter: formatter)
MultiLogger.add_logger('campaign', formatter: formatter)
MultiLogger.add_logger('campaign_sidekiq', formatter: formatter)
MultiLogger.add_logger('campaign_show_sidekiq', formatter: formatter)
MultiLogger.add_logger('sms_spider', formatter: formatter)
MultiLogger.add_logger('pusher', formatter: formatter)
