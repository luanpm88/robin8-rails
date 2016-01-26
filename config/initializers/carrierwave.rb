::CarrierWave.configure do |config|
  config.storage             = :qiniu
  config.qiniu_access_key    =  Rails.application.secrets.qiniu[:access_key]
  config.qiniu_secret_key    =  Rails.application.secrets.qiniu[:secret_key]
  config.qiniu_bucket        =  Rails.application.secrets.qiniu[:bucket]
  config.qiniu_bucket_domain =  Rails.application.secrets.qiniu[:bucket_domain]
end
