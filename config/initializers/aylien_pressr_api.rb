AylienPressrApi.configure do |config|
  config.username = Rails.application.secrets.robin_api_user
  config.password = Rails.application.secrets.robin_api_pass
  if Rails.application.secrets.robin_api_url
    config.base_uri = Rails.application.secrets.robin_api_url
  end
end
