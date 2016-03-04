class TmpIdentity < ActiveRecord::Base

  scope :from_pc, -> {where(:from_type => 'pc')}
  scope :from_app, -> {where(:from_type => 'app')}

  scope :valid, ->{ where("provider = 'weibo' or (provider='wechat' and from_type='app')")}
  scope :provider , -> (provider) {where(:provider => provider)}

  after_save :cal_identity_influence, :on => :create

  def self.find_for_oauth(auth, origin_auth, current_kol = nil)
    identity = find_by(provider: auth[:provider], uid: auth[:uid]) || create_identity(auth, origin_auth)
    current_kol.record_identity(identity)           if current_kol
    identity
  end

  def self.get_identities(kol_uuid)
    self.where(:kol_uuid => kol_uuid)
  end

  private
  def cal_identity_influence
    if self.provider == 'sina'
      Influence::Influence.init_identity(self.kol_uuid)
      CalInfluenceWorker.perform_async('identity', self.kol_uuid, self.id, nil)
    end
  end

end



