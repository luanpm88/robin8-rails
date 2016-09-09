if Rails.env.staging?
  Airbrake.configure do |config|
    config.project_key = 'dee3de294163aac01d95fd126150626f'
    config.project_id = -1
    config.host = 'bug.robin8.net'
    config.port = 80
    config.secure = config.port == 443
    config.ignore << 'ActionController::InvalidCrossOriginRequest'
  end
end

if Rails.env.production?
  Airbrake.configure do |config|
    config.project_key = '0dc2bc446c92ca946389c5b7da71895f'
    config.project_id = -1
    config.host = 'bug.robin8.net'
    config.port = 80
    config.secure = config.port == 443
    config.ignore << 'ActionController::InvalidCrossOriginRequest'
  end
end
