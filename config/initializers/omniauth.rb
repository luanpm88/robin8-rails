Rails.application.config.middleware.use OmniAuth::Builder do
  provider :weibo, Rails.application.secrets.weibo[:app_key], Rails.application.secrets.weibo[:app_secret]
  provider :wechat, Rails.application.secrets.wechat[:app_id], Rails.application.secrets.wechat[:app_secret]

  on_failure { |env| AuthenticationsController.action(:failure).call(env) }
end
