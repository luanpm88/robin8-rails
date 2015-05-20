AylienTextApi.configure do |config|
  config.app_id        =    Rails.application.secrets.textapi[:app_id]
  config.app_key       =    Rails.application.secrets.textapi[:app_key]
  if Rails.application.secrets.textapi[:base_uri]
    config.base_uri = Rails.application.secrets.textapi[:base_uri]
  end
end
