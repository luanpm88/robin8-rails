class PublicWechatLogin < ActiveRecord::Base
  def self.generate_account_login(username, password, visitor_cookies, token)
    password_encrypted = PasswordHandle.encode_pwd(password)
    PublicWechatLogin.create(login_type: 'account', username: username, password_encrypted:password_encrypted,
                             visitor_cookies: visitor_cookies, token: token )
  end

 def self.generate_qrcode_login(username, password, visitor_cookies, ticket, appid, uuid, operation_seq, redirect_url)
   password_encrypted = PasswordHandle.encode_pwd(password)
   PublicWechatLogin.create(login_type: 'qrcode', username: username, password_encrypted:password_encrypted,
                            visitor_cookies: visitor_cookies, ticket: ticket, appid: appid, uuid: uuid,
                            operation_seq: operation_seq, login_time: Time.now, redirect_url: redirect_url)
 end

  def self.success_qrcode_logoin(login_id, visitor_cookies, token)
    webchat_login = PublicWechatLogin.find login_id
    return if webchat_login.blank?
    webchat_login.update_column(visitor_cookies: visitor_cookies, token: token)
  end


  # 远程服务器
  ServerIp = 'http://139.196.36.27'
  ApiToken = 'b840fc02d524045429941cc15f59e41cb7be6c52'
  def get_info(info_type = nil)
    params = {:api_token => ApiToken, :email => self.username, :cookie => self.visitor_cookies,
              :user_agent => Weixin::PublicLogin::UserAgent, :token => self.token}
    params["#{info_type}"] = 1 if info_type.present?
    return RestClient.get("#{ServerIp}/weixin/report", {:params => params})
  end


  #TODO
  def sync_to

  end
end
