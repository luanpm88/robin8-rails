require 'exception_notification/rails'
require 'exception_notification/sidekiq'
require 'exception_notifier/async_mail_notifier'

ExceptionNotification.configure do |config|
  config.ignored_exceptions += %w(ActionView::TemplateError
                                  ActionController::BadRequest
                                  ActionView::MissingTemplate
                                  ActionController::UrlGenerationError)

  config.ignore_if do |exception, options|
    Rails.env.development?
  end

  # Email notifier sends notifications by email.
  # config.add_notifier :email, {
  #   :email_prefix         => "[Exception] ",
  #   :sender_address       => %{"Exception Notification" <exception.notifier@robin8.com>},
  #   :exception_recipients => %w{dev_notify@robin8.com}
  # }

  host_name = (`hostname`).gsub("\n", "")

  config.add_notifier :async_mail, {
    :sender           => %{"Exception Notification from #{host_name}" <exception.notify@robin8.com>},
    :recipients       => %w{dev_notify@robin8.com}
  }
end
