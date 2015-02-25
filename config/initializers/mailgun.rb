Mailgun.configure do |config|
  config.api_key = Rails.application.secrets.mailgun[:api_base_url]
  config.domain  = Rails.application.secrets.mailgun[:api_key]
end
