Mailgun.configure do |config|
  config.api_key = Rails.application.secrets.smtp[:api_key]
  config.domain  = Rails.application.secrets.smtp[:public_api_key]
end