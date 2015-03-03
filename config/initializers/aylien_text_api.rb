AylienTextApi.configure do |config|
  config.app_id        =    Rails.application.secrets.textapi[:app_id]
  config.app_key       =    Rails.application.secrets.textapi[:app_key]
end
