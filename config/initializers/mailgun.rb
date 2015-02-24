Mailgun.configure do |config|
  config.api_key = Rails.application.secrets.mailgun[:api_key]
  config.domain  = Rails.application.secrets.mailgun[:public_api_key]
end