IMGKit.configure do |config|
  config.wkhtmltoimage = Rails.application.secrets.wkhtmltoimage_path || '/usr/bin/wkhtmltoimage'
end
