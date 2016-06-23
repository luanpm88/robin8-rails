require 'exception_notification/rails'
require 'exception_notification/sidekiq'
require 'exception_notifier/async_mail_notifier'

ExceptionNotification.configure do |config|
  config.ignored_exceptions += %w(ActionView::TemplateError
                                  ActionController::BadRequest
                                  ActionView::MissingTemplate
                                  ActionController::UrlGenerationError)

  config.ignore_if do |exception, options|
    skip = false

    key = "#{Rails.application.class.parent.to_s} #{exception.inspect} "
    key += exception.backtrace.slice(0,1).join("\n") unless exception.backtrace.blank?

    begin
      if !!Redis::Objects.redis.get(key)
        skip = Redis::Objects.redis.incr(key) % 50 != 0
      else
        Redis::Objects.redis.setex(key, 60 * 30, 0)
        skip = false
      end
    rescue
      Rails.logger.error("异常通知邮件过滤出错!")
    end

    Rails.env.development? || !!skip
  end

  # Email notifier sends notifications by email.
  # config.add_notifier :email, {
  #   :email_prefix         => "[Exception] ",
  #   :sender_address       => %{"Exception Notification" <exception.notifier@robin8.com>},
  #   :exception_recipients => %w{dev_notify@robin8.com}
  # }

  host_name = (`hostname`).gsub("\n", "")
  app_name = Rails.application.class.parent.to_s

  config.add_notifier :async_mail, {
    :sender           => %{"[#{app_name}] Exception Notification from #{host_name}" <exception.notify@robin8.com>},
    :recipients       => %w{dev_notify@robin8.com}
  }
end
