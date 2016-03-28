class TmpIdentity < ActiveRecord::Base

  scope :from_pc, -> {where(:from_type => 'pc')}
  scope :from_app, -> {where(:from_type => 'app')}

  scope :provider , -> (provider) {where(:provider => provider)}
  scope :order_by_provider, -> { order("case identities.provider  when 'wechat' then 3 when 'weibo' then 2 else 1 end  desc, score desc") }

  after_save :cal_identity_influence, :on => :create

  def self.find_for_oauth(auth, origin_auth, current_kol = nil)
    identity = find_by(provider: auth[:provider], uid: auth[:uid]) || create_identity(auth, origin_auth)
    current_kol.record_identity(identity)           if current_kol
    identity
  end

  def self.get_identities(kol_uuid)
    self.where(:kol_uuid => kol_uuid)
  end

  def self.test
    identity = TmpIdentity.new
    identity.provider = 'weibo'
    identity.uid = 'afefefwefwf'
    identity.followers_count  = 3000
    identity.statuses_count  = 1300
    identity.registered_at = 7.months.ago
    identity.verified = true
    identity.from_type = 'app'
    identity.kol_uuid = Time.now.to_i
    identity.save
  end

  def self.create_identity_from_app(params)
    TmpIdentity.create(provider: params[:provider], uid: params[:uid], token: params[:token], from_type: params[:from_type],
                    name: params[:name], url: params[:url], avatar_url: params[:avatar_url], desc: params[:desc], unionid: params[:unionid],
                    followers_count: params[:followers_count],friends_count: params[:friends_count],statuses_count: params[:statuses_count],
                    registered_at: params[:registered_at],refresh_token: params[:refresh_token],serial_params: params[:serial_params],
                    kol_uuid: params[:kol_uuid], verified: params[:verified])
  end


  def self.get_name(kol_uuid, kol_id)
    name = Kol.find(kol_id).name rescue nil
    name = TmpIdentity.where(:kol_uuid => kol_uuid).order_by_provider.first.name rescue nil  if name.blank?
    name
  end

  def self.get_avatar_url(kol_uuid, kol_id)
    avatar_url = Kol.find(kol_id).avatar.url rescue nil
    avatar_url = TmpIdentity.where(:kol_uuid => kol_uuid).order_by_provider.first.avatar_url rescue nil   if avatar_url.blank?
    avatar_url
  end

  private
  def cal_identity_influence
    if self.provider == 'weibo'
      # Influence::Value.init_identity(self.kol_uuid)
      Influence::Identity.cal_score(kol_uuid,self.id)
    end
  end


end



