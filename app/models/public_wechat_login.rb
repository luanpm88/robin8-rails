class PublicWechatLogin < ActiveRecord::Base
  def self.generate_account_login(username, password, visitor_cookies, token)
    password_encrypted = PasswordHandle.encode_pwd(password)
    PublicWechatLogin.create(login_type: 'account', username: username, password_encrypted:password_encrypted,
                             visitor_cookies: visitor_cookies, token: token )
  end

 def self.generate_qrcode_login(username, password, login_cookies, ticket, appid, uuid, operate_seq)
   password_encrypted = PasswordHandle.encode_pwd(password)
   PublicWechatLogin.create(login_type: 'qrcode', username: username, password_encrypted:password_encrypted,
                            login_cookies: login_cookies, ticket: ticket, appid: appid, uuid: uuid,
                            operate_seq: operate_seq, login_time: Time.now)
 end

  def self.success_qrcode_logoin(login_id, visitor_cookies, token)
    webchat_login = PublicWechatLogin.find login_id
    return if webchat_login.blank?
    webchat_login.update_column(visitor_cookies: visitor_cookies, token: token)
  end

  #TODO
  def sync_to

  end
end
