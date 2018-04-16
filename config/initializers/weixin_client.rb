# $weixin_client ||= WeixinAuthorize::Client.new(Rails.application.secrets.wechat[:app_id],Rails.application.secrets.wechat[:app_secret])
# puts "======weixin_client init===#{$weixin_client.is_valid?}"

unless Rails.env.test?
  namespace = 'redis_wechat_authorize'
  wechat_authorize = Redis.new(host: Rails.application.secrets[:redis][:host],
                               db: 1, # access_token多次获取，看是否是db冲突
                               password: Rails.application.secrets[:redis][:password])
  $redis_wechat_authorize = Redis::Namespace.new(namespace, redis: wechat_authorize)

  # Clean keys from this namespace on application restart
  keys = $redis_wechat_authorize.keys('*')
  keys.each {|key| $redis_wechat_authorize.del(key)}

  WeixinAuthorize.configure do |config|
    config.redis = $redis_wechat_authorize
  end

  $weixin_client ||= WeixinAuthorize::Client.new(Rails.application.secrets.wechat[:app_id],
                                                 Rails.application.secrets.wechat[:app_secret])

  puts "======weixin_client init===#{$weixin_client.is_valid?}"
  Rails.logger.wechat.info "======weixin_client init===#{$weixin_client.is_valid?}"
  Rails.logger.wechat.info "======weixin_client access_token===#{$weixin_client.access_token}"
  Rails.logger.wechat.info "======weixin_client access_token.expired_at===#{$weixin_client.expired_at}"
  t = $weixin_client.token_store
  Rails.logger.wechat.info "======weixin_client redis_key===#{t.client.redis_key}"
  Rails.logger.wechat.info "======weixin_client expired_at===#{t.client.expired_at}"
end
