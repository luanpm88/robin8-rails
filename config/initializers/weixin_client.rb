# WeixinAuthorize.configure do |config|
#   config.redis = $redis
# end

$weixin_client ||= WeixinAuthorize::Client.new(Rails.application.secrets.wechat[:app_id],Rails.application.secrets.wechat[:app_secret])

puts "======weixin_client init===#{$weixin_client.is_valid?}"
Rails.logger.wechat_campaign.info "======weixin_client init===#{$weixin_client.is_valid?}"
Rails.logger.wechat_campaign.info "======weixin_client access_token===#{$weixin_client.access_token}"
Rails.logger.wechat_campaign.info "======weixin_client access_token.expired_at===#{$weixin_client.expired_at}"
t = $weixin_client.token_store
Rails.logger.wechat_campaign.info "======weixin_client redis_key===#{t.client.redis_key}"
Rails.logger.wechat_campaign.info "======weixin_client expired_at===#{t.client.expired_at}"
