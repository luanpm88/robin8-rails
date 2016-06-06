$weixin_client ||= WeixinAuthorize::Client.new(Rails.application.secrets.wechat[:app_id],Rails.application.secrets.wechat[:app_secret], verify_ssl: true)
puts "======weixin_client init===#{$weixin_client.is_valid?}"

