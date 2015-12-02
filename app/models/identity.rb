class Identity < ActiveRecord::Base
  belongs_to :user
  belongs_to :kol  # should have used polymorphic association here
  has_many :kol_categories#, -> { unscope(where: :scene)}
  has_many :iptc_categories, -> { unscope(where: :scene)}, :through => :kol_categories
  WxThirdProvider = 'wechat_third'
  after_save :spider_weibo_data

  scope :provider , -> (provider) {where(:provider => provider)}

  def self.find_for_oauth(auth, origin_auth, current_kol = nil)
    find_by(provider: auth[:provider], uid: auth[:uid]) || create_identity(auth, origin_auth)
    # if identity
    #   current_kol.record_provide_info(identity, 'exist')         if current_kol
    # else
    #   identity = create_identity(auth, origin_auth)
    #   current_kol.record_provide_info(identity)                  if current_kol
    # end
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

  private
  def spider_weibo_data
    if self.provider == "weibo" and self.kol_id.present? and self.has_grabed == false
      self.update(:has_grabed => true)
      IntegrationWithDataEngineWorker.perform_async 'spider_weibo', self.id
    end
  end
end



