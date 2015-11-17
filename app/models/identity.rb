class Identity < ActiveRecord::Base
  belongs_to :user
  belongs_to :kol  # should have used polymorphic association here
  has_many :kol_categories
  has_many :iptc_categories, :through => :kol_categories
  WxThirdProvider = 'wx_third'

  def self.find_for_oauth(auth, current_kol = nil)
    identity = find_by(provider: auth[:provider], uid: auth[:uid])
    if identity
      current_kol.record_provide_info(identity, 'exist')         if current_kol
    else
      identity = create_identity(auth)
      current_kol.record_provide_info(identity)    if current_kol
    end
    identity
  end

  def self.create_identity(auth)
    create(uid: auth[:uid], provider: auth[:provider], token: auth[:token], url: auth[:url],
           token_secret: auth[:token_secret], name: auth[:name], avatar_url: auth[:avatar_url],
           desc: auth[:desc],  serial_params: auth.to_json )
  end

  # 查找 微信第三方平台账号
  def self.find_by_third_authorize(authorizer_info, current_kol = nil)
    identity =  find_by(:provider => WxThirdProvider, :uid => authorizer_infoe["appid"])
    if !identity
      auth = {}
      auth[:uid] = authorizer_info["appid"]
      auth[:provider] = WxThirdProvider
      auth[:name] =  authorizer_info["authorizer_info"]["nick_name"]
      auth[:avatar_url] = authorizer_info["authorizer_info"]["head_img"]
      identity = create_identity(auth)
    end
    identity
  end

  def total_tasks
    14
  end

  def last30_posts
    22
  end

end



