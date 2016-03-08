class Identity < ActiveRecord::Base
  belongs_to :user
  belongs_to :kol  # should have used polymorphic association here
  has_many :kol_categories#, -> { unscope(where: :scene)}
  has_many :iptc_categories, -> { unscope(where: :scene)}, :through => :kol_categories

  scope :from_pc, -> {where(:from_type => 'pc')}
  scope :from_app, -> {where(:from_type => 'app')}

  scope :valid, ->{ where("provider = 'weibo' or (provider='wechat' and from_type='app')")}



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

  def self.create_identity_from_app(params)
    Identity.create(provider: params[:provider], provider: params[:provider], uid: params[:uid], token: params[:token],
                    name: params[:name], url: params[:url], avatar_url: params[:avatar_url], desc: params[:desc], unionid: params[:unionid],
                    followers_count: params[:followers_count],friends_count: params[:friends_count],statuses_count: params[:statuses_count],
                    registered_at: params[:registered_at],refresh_token: params[:refresh_token],serial_params: params.to_json,kol_id: kol_id)
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
    return if self.provider != 'weibo' || self.registered_at.present?
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

  private
  def spider_weibo_data
    if self.provider == "weibo" and self.kol_id.present? and self.has_grabed == false
      self.update(:has_grabed => true)
      IntegrationWithDataEngineWorker.perform_async 'spider_weibo', self.id
    end
  end
end



