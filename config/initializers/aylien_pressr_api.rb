AylienPressrApi.configure do |config|
  config.username        =    Rails.application.secrets.robin_api_user
  config.password        =    Rails.application.secrets.robin_api_pass
end
