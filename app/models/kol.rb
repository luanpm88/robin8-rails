class Kol < ActiveRecord::Base
  include Concerns::PayTransaction
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable, allow_unconfirmed_access_for: 1.years

  has_many :identities, -> {order('updated_at desc')}, :dependent => :destroy, autosave: true

  has_many :kol_categories
  has_many :iptc_categories, -> { unscope(where: :scene)} , :through => :kol_categories

  has_many :campaign_invites
  has_many :campaigns, :through => :campaign_invites
  has_many :articles
  has_many :wechat_article_performances, as: :sender
  has_many :article_comments, as: :sender
  has_many :kol_profile_screens
  has_many :interested_campaigns
  after_create :create_campaign_invites_after_signup
  after_save :update_click_threshold

  mount_uploader :avatar, :ImageUploader

  has_many :withdraws

  def email_required?
    false if self.provider != "signup"
  end

  def password_required?
    false if self.provider != "signup"
  end

  GENDERS = {
    :NONE => 0,
    :MALE => 1,
    :FEMALE => 2
  }

  include Models::Identities
  extend Models::Oauth


  def record_identity(identity)
    Rails.cache.write("provide_info_#{self.id}", identity)
  end

  #get
  def get_identity
    info  = Rails.cache.read("provide_info_#{self.id}")
    Rails.cache.delete("provide_info_#{self.id}")
    info
  end

  def category_size
    iptc_categories.size
  end


  class EmailValidator < ActiveModel::Validator
    def validate(record)
      if record.new_record? and User.exists?(:email=>record.email)
        record.errors[:email] << I18n.t('kols.email_already_been_taken')
      end
    end
  end

  validates_with EmailValidator

  def self.check_mobile_number mobile_number
    return Kol.where("mobile_number" => mobile_number).present?
  end

  def active
    not confirmed_at.nil?
  end


  def categories
    iptc_categories.reload.map do |c|
      { :id => c.id, :label => c.label }
    end
  end

  def screens
    kol_profile_screens.reload.map do |c|
      { :id => c.id, :url => c.url, :thumbnail => c.thumbnail, :social_name => c.social_name }
    end
  end

  def serializable_hash(options={})
    res = super(options)
    sign_in_info = {
      "sign_in_count" => self.sign_in_count,
      "last_sign_in_at" => self.last_sign_in_at
    }
    res["sign_in_info"] = sign_in_info
    res
  end

  def self.find_for_oauth(auth)
    identity = Identity.find_by(provider: auth[:provider], uid: auth[:uid])
    if identity
      return identity.kol
    else
      return nil
    end
  end

  def all_score
    wechat_score  = identity_score('wechat')
    wechat_third_score = identity_score('wechat_third')
    weibo_score = identity_score('weibo')
    total_score =  data_score +  wechat_score +   wechat_third_score +   weibo_score
    {:total => total_score , :data => data_score * 100 / 40, :weibo=> weibo_score * 100 / 20,
     :wechat => wechat_score * 100 / 20,  :wechat_third => wechat_third_score * 100 / 20 }
  end

  def data_score
    (10 + [self.first_name, self.last_name, self.mobile_number, self.city, self.date_of_birthday, self.gender].compact.size * 5)
  end

  def identity_score(provider)
    (self.identities.provider(provider).collect{|t| t.score}.max  || 0  )
  end

  def create_campaign_invites_after_signup
    CampaignSyncAfterSignup.perform_async(self.id)
  end


  def self.fetch_kol(kol_id)
    Rails.cache.fetch("kol_#{kol_id}", :expires_in => 1.days) do
      Kol.find(kol_id)
    end    rescue nil
  end

  def update_click_threshold
    if five_click_threshold_changed? || total_click_threshold_changed?
      Rails.cache.delete("kol_#{self.id}")
    end
  end

  def has_pending_withdraw
    withdraws.pending.size > 0
  end

  def get_private_token
    if !self.private_token
      self.update_column(:private_token, SecureRandom.hex)
    end
    self.private_token
  end

  def get_issue_token
    AuthToken.issue_token(get_private_token)
  end

  def self.app_auth(private_token)
    Kol.find_by :private_token => private_token    rescue nil
  end
end
