# $weixin_client ||= WeixinAuthorize::Client.new(Rails.application.secrets.wechat[:app_id],Rails.application.secrets.wechat[:app_secret])
# puts "======weixin_client init===#{$weixin_client.is_valid?}"

unless Rails.env.test?
  namespace = 'redis_wechat_authorize'
  local_redis = Redis.new(:host => '127.0.0.1', :db => 1,
                          :password => Rails.application.secrets[:local_redis_password])
  $redis_wechat_authorize = Redis::Namespace.new(namespace, :redis => local_redis)

  # Clean keys from this namespace on application restart
  keys = $redis_wechat_authorize.keys('*')
  keys.each {|key| $redis_wechat_authorize.del(key)}

  WeixinAuthorize.configure do |config|
    config.redis = $redis_wechat_authorize
  end

  $weixin_client ||= WeixinAuthorize::Client.new(Rails.application.secrets.wechat[:app_id],
                                                 Rails.application.secrets.wechat[:app_secret])
  puts "======weixin_client init===#{$weixin_client.is_valid?}"
end
