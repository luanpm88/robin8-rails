if Rails.env.production? || Rails.env.staging?
  Sidekiq.configure_server do |config|
    config.redis = { url: Rails.application.secrets[:redis][:url] }
  end
  Sidekiq.configure_client do |config|
   config.redis = { url: Rails.application.secrets[:redis][:url] }
  end
end
