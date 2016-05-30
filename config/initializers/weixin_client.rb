$weixin_client ||= WeixinAuthorize::Client.new(Rails.application.secrets.wechat[:app_key],Rails.application.secrets.wechat[:app_secret])
puts "======weixin_client init===#{$weixin_client.is_valid?}"

