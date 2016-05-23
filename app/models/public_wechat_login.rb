class PublicWechatLogin < ActiveRecord::Base
  # status 1, 0

  def self.generate_account_login(kol_id, username, password, visitor_cookies, token)
    password_encrypted = PasswordHandle.encode_pwd(password)
    wechat_login =  PublicWechatLogin.create(kol_id: kol_id, login_type: 'account', username: username, password_encrypted:password_encrypted,
                             visitor_cookies: visitor_cookies, token: token, status: 1 )
    wechat_login.sync_account_to_identity
    wechat_login
  end

 def self.generate_qrcode_login(kol_id, username, password, visitor_cookies, ticket, appid, uuid, operation_seq, redirect_url)
   password_encrypted = PasswordHandle.encode_pwd(password)
   PublicWechatLogin.create(kol_id: kol_id, login_type: 'qrcode', username: username, password_encrypted:password_encrypted,
                            visitor_cookies: visitor_cookies, ticket: ticket, appid: appid, uuid: uuid,
                            operation_seq: operation_seq, login_time: Time.now, redirect_url: redirect_url)
   wechat_login
 end

  def self.success_qrcode_logoin(login_id, visitor_cookies, token)
    webchat_login = PublicWechatLogin.find login_id
    return if webchat_login.blank?
    webchat_login.update_columns(visitor_cookies: visitor_cookies, token: token, status: '1')
    wechat_login.sync_account_to_identity
    wechat_login
  end


  # 远程服务器
  ServerIp = 'http://139.196.36.27'
  ApiToken = 'b840fc02d524045429941cc15f59e41cb7be6c52'
  def get_info(info_type = nil)
    params = {:api_token => ApiToken, :email => self.username, :cookie => self.visitor_cookies,
              :user_agent => Analysis::PublicLogin::UserAgent, :token => self.token}
    params["#{info_type}"] = 1 if info_type.present?
    return RestClient.get("#{ServerIp}/weixin/report", {:params => params})
  end


  #登陆成功同步到到identity account
  def sync_account_to_identity
    public_wechat_identity = AnalysisIdentity.find_or_initialize_by(:kol_id => self.kol_id, :name => self.username)
    public_wechat_identity.provider = 'public_wechat'
    public_wechat_identity.password_encrypted = self.password_encrypted
    public_wechat_identity.authorize_time = Time.now
    public_wechat_identity.save
  end

  #每次获取用户信息后 需要同步更新用户账户
  def sync_info_to_identity(user_info)
    public_wechat_identity = AnalysisIdentity.find(:kol_id => self.kol_id, :name => self.username)
    return if public_wechat_identity.blank?
    public_wechat_identity.nick_name = user_info['nick_name']
    public_wechat_identity.logo_url = user_info['logo_url']
    public_wechat_identity.user_name = user_info['user_name']
    public_wechat_identity.save
  end
end
