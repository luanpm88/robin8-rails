class Identity < ActiveRecord::Base
  belongs_to :user
  belongs_to :kol  # should have used polymorphic association here
  has_many :kol_categories#, -> { unscope(where: :scene)}
  has_many :iptc_categories, -> { unscope(where: :scene)}, :through => :kol_categories

  scope :from_pc, -> {where(:from_type => 'pc')}
  scope :from_app, -> {where(:from_type => 'app')}
  scope :order_by_provider, -> { order("case identities.provider  when 'wechat' then 3 when 'weibo' then 2 else 1 end  desc") }

  scope :valid, -> { }
  scope :by_date, ->(date){where("created_at > '#{date.beginning_of_day}' and created_at < '#{date.end_of_day}' ") }


  WxThirdProvider = 'wechat_third'
  after_save :spider_weibo_data, :get_value_info, :on => :create

  scope :provider , -> (provider) {where(:provider => provider)}

  def self.find_for_oauth(auth, origin_auth, current_kol = nil)
    identity = find_by(provider: auth[:provider], uid: auth[:uid]) || create_identity(auth, origin_auth)
    current_kol.record_identity(identity)           if current_kol
    identity
  end

  def self.switch_package_to_params(package)
    params = {}
    params[:uid] = package["authorization_info"]["authorizer_appid"]      rescue nil
    params[:provider] = WxThirdProvider
    params[:name] =  package["authorizer_info"]["nick_name"]         rescue nil
    params[:avatar_url] = package["authorizer_info"]["head_img"]     rescue nil
    params[:service_type_info] = package["authorizer_info"]["service_type_info"]["id"]    rescue nil
    params[:verify_type_info] = package["authorizer_info"]["verify_type_info"]["id"]      rescue nil
    params[:wx_user_name] = package["authorizer_info"]["user_name"]                       rescue nil
    params[:alias] = package["authorizer_info"]["alias"]                                  rescue nil
    return params
  end


  def self.create_identity(auth, origin_auth = {})
    create!(uid: auth[:uid], provider: auth[:provider], token: auth[:token], url: auth[:url],
            token_secret: auth[:token_secret], name: auth[:name], avatar_url: auth[:avatar_url],
            desc: auth[:desc], service_type_info: auth[:service_type_info],
            verify_type_info: auth[:verify_type_info], wx_user_name: auth[:wx_user_name],
            alias: auth[:alias], unionid:auth[:unionid], serial_params: origin_auth.to_json
    )
  end

  def self.create_identity_from_app(params, identity = nil)
    if identity
      identity.update_attributes(provider: params[:provider], uid: params[:uid], token: params[:token], from_type: params[:from_type],
                                 name: params[:name], url: params[:url], avatar_url: params[:avatar_url], desc: params[:desc], unionid: params[:unionid],
                                 followers_count: params[:followers_count],friends_count: params[:friends_count],statuses_count: params[:statuses_count],
                                 registered_at: params[:registered_at],refresh_token: params[:refresh_token],serial_params: params[:serial_params],
                                 kol_id: params[:kol_id],  verified: params[:verified], refresh_time: Time.now, access_token_refresh_time: Time.now,
                                 service_type_info: params[:service_type_info], verify_type_info: params[:verify_type_info],
                                 wx_user_name: params[:wx_user_name], alias: params[:alias])
    else
      Identity.create(provider: params[:provider], uid: params[:uid], token: params[:token], from_type: params[:from_type],
                      name: params[:name], url: params[:url], avatar_url: params[:avatar_url], desc: params[:desc], unionid: params[:unionid],
                      followers_count: params[:followers_count],friends_count: params[:friends_count],statuses_count: params[:statuses_count],
                      registered_at: params[:registered_at],refresh_token: params[:refresh_token],serial_params: params[:serial_params],
                      kol_id: params[:kol_id],  verified: params[:verified], refresh_time: Time.now, access_token_refresh_time: Time.now,
                      service_type_info: params[:service_type_info], verify_type_info: params[:verify_type_info],
                      wx_user_name: params[:wx_user_name], alias: params[:alias])
    end
  end


  def total_tasks
    0
  end

  def complete_tasks
    0
  end

  def last30_posts
    0
  end

  def score
    value = 5
    value += 10 if  [audience_age_groups, audience_gender_ratio, audience_regions, (self.iptc_categories.size > 0 ? '1' : nil)].compact.size > 0
    value += 5  if  [edit_forward, origin_publish, forward, origin_comment, partake_activity, panel_discussion,
                     undertake_activity, image_speak,  give_speech].compact.size > 0
    value
  end


  SinaUserServer = 'https://api.weibo.com/2/users/show.json'
  def get_value_info
    return if self.provider != 'weibo' || self.registered_at.present? || Rails.env.development? || Rails.env.test?
    respond_json = RestClient.get SinaUserServer , {:params => {:access_token => self.token, :uid => self.uid}}       rescue ""
    respond = JSON.parse respond_json    rescue  {"error" => 1}
    #返回错误
    if respond["error"]
      return false;
    else
      self.followers_count =  respond["followers_count"]
      self.statuses_count = respond["statuses_count"]
      self.registered_at = respond["created_at"]
      self.verified = respond["verified"]
      self.serial_params = respond_json
      self.save
    end
  end

  def get_weibo_url
    self.url || "http://weibo.com/#{self.uid}"
  end

  # Checks cridentials againtst wechat/weibo/qq api
  def self.is_valid_identity? provider, client_access_token, uid
    if provider == 'weibo'
      weibo_url = "https://api.weibo.com/2/users/show.json?access_token=#{client_access_token}&uid=#{uid}"
      json_response = RestClient.get(weibo_url)
      if json_response.code == 200
        body = JSON.parse(json_response.body)
        # client is valid if returned JSON contains e.g. client 'id'
        body.has_key? "id"
      else
        false
      end
    elsif provider == 'wechat'
      # uid is wechat openid, token is token returned by wechat oauth process
      res = $weixin_client.get_oauth_userinfo(uid, client_access_token)
      # valid if response returns openid, and it is the same as client's openid
      openid = res.result['openid'] rescue false
      openid == uid
    elsif provider == 'qq'
      # Based on documentation: http://wiki.open.qq.com/wiki/website/OpenAPI调用说明_OAuth2.0
      req1_url = "https://graph.qq.com/oauth2.0/me?access_token=#{client_access_token}"
      res1 = RestClient.get(req1_url)
      if res1.code == 200
        cleaned_response = res1.match(/{.+}/)[0] rescue nil
        res1_body = JSON.parse(cleaned_response)
        oauth_consumer_key = res1_body['client_id']
        openid =res1_body['openid']

        req2_url = "https://graph.qq.com/user/get_user_info?access_token=#{client_access_token}&oauth_consumer_key=#{oauth_consumer_key}&openid=#{openid}"
        res2 = RestClient.get(req2_url)
        if res2.code == 200
          res2_body = JSON.parse(res2.body)
          return (res2_body.has_key?('ret') and res2_body['ret'] == 0)
        end
      end
      return false
    elsif provider == 'facebook'
        facebook_url = "https://graph.facebook.com/me/?access_token=#{client_access_token}"
        res_fb = RestClient.get(facebook_url)
        json_res = JSON.parse(res_fb)
        return json_res["id"] == uid;
    end
  end

  private
  def spider_weibo_data
    if self.provider == "weibo" and self.kol_id.present? and self.has_grabed == false
      self.update(:has_grabed => true)
      IntegrationWithDataEngineWorker.perform_async 'spider_weibo', self.id
    end
  end
end
