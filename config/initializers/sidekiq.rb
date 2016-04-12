if Rails.env.production? || Rails.env.staging?
  Sidekiq.configure_server do |config|
    config.redis = { url: Rails.application.secrets[:redis][:url], password: Rails.application.secrets[:redis][:password] }
  end
  Sidekiq.configure_client do |config|
   config.redis = { url: Rails.application.secrets[:redis][:url], password: Rails.application.secrets[:redis][:password] }
  end
end
