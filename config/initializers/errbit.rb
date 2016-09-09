if Rails.env.staging?
  Airbrake.configure do |config|
    config.api_key = '7653ded9d74fa11f84a09612a9942a35'
    config.host = 'errbit.i-spread.cn'
    config.port = 80
    config.secure = config.port == 443
    config.ignore << 'ActionController::InvalidCrossOriginRequest'
  end
end
