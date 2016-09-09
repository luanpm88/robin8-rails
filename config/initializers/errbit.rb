if Rails.env.production?
  Airbrake.configure do |config|
    config.host = 'http://bug.robin8.net'
    config.project_id = -1
    config.project_key = '0dc2bc446c92ca946389c5b7da71895f'
  end
elsif Rails.env.staging?
  Airbrake.configure do |config|
    config.host = 'http://bug.robin8.net'
    config.project_id = -1
    config.project_key = 'dee3de294163aac01d95fd126150626f'
  end
end
