class User < ActiveRecord::Base
  include Concerns::PayTransaction

  include Users::AlipayHelper
  attr_accessor :login

  has_many :transactions, :as => :account
  has_many :alipay_orders
  has_one  :invoice
  has_one  :invoice_receiver
  has_many :invoice_histories

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, #:validatable, :confirmable,
         :omniauthable, :invitable, :authentication_keys => [:login]

  has_many :identities, dependent: :destroy

  has_many :kols_lists, dependent: :destroy
  has_many :contacts, through: :media_lists

  has_many :campaigns, -> {where.not(status: 'revoked')}
  has_many :campaign_invites, through: :campaigns

  has_many :article_comments, as: :sender

  has_many :private_kols
  has_many :kols, through: :private_kols
  has_many :paid_transactions, -> {where("direct='payout' or direct='income'")}, class_name: 'Transaction', as: :account
  belongs_to :kol

  validates_presence_of :name, :if => Proc.new{|user| (user.new_record? and self.kol_id.blank?) or user.name_changed?}
  after_create :init_appid

  PlatformMobile = '13088888888'
  def self.get_platform_account
    User.find_by :mobile_number => PlatformMobile
  end
  validates_presence_of :mobile_number, :if => Proc.new{|user| user.new_record? or user.mobile_number_changed?}
  validates_presence_of :password, :if => Proc.new { |user| user.encrypted_password_changed? }
  validates_uniqueness_of :mobile_number, allow_blank: true, allow_nil: true, :message => "手机号码已经存在"
  validates_uniqueness_of :name, allow_blank: true, allow_nil: true, :message => "品牌名称已经存在"
  validates_uniqueness_of :email, allow_blank: true, allow_nil: true, :message => "邮箱已经存在"
  validates_length_of :password, :minimum => 6, :message => "密码长度最少为6位", :if => Proc.new { |user| user.encrypted_password_changed? }

  include Models::Identities

  # class EmailValidator < ActiveModel::Validator
  #   def validate(record)
  #     if record.new_record? and Kol.exists?(:email=>record.email) and (record.email != nil or record.email != '')
  #       record.errors[:base] << "邮箱已存在"
  #     end
  #   end
  # end

  # validates_with EmailValidator

  extend FriendlyId
  friendly_id :email, use: :slugged

  extend Models::Oauth

  def login= login
    @login = login
  end

  def login
    @login || self.mobile_number || self.email
  end

  def invited_users_list
    invited_id = User.where(invited_by_id: needed_user.id).map(&:id)
    return invited_id.push(needed_user.id)
  end

  def current_user_features
    users_id = invited_users_list
    UserFeature.where :user_id => users_id
  end

  def is_feature_available?(slug)
    users_id = invited_users_list
    Feature.joins(:user_features).where(:user_features =>{:user_id => users_id,:available_count => 0..INFINITY},:slug=>slug).exists?
  end

  def used_count_by_slug(slug)
    case slug
    when 'seat'
      seat_count
    when 'newsroom'
      newsroom_count
    when 'press_release'
      release_count
    when 'smart_release'
      smart_release_count
    when 'media_monitoring'
      stream_count
    when 'personal_media_list'
      media_lists_count
    else
      0
    end
  end

  def available_features
     current_user_features.where("user_features.available_count > '0'")
  end

  def is_primary?
    is_primary != false
  end


  def manageable_users
    User.where(invited_by_id: self.id)
  end

  def name
    super.present? ? super : "#{first_name} #{last_name}"
  end

  def display_name
    if name.present?
      user_name = name
    elsif first_name.present? && last_name.present?
      user_name = "#{first_name} #{last_name}"
    end
    user_name && email.present? ? "#{user_name}, #{email}" : "#{user_name}#{email}"
  end

  def as_json(options={})
    super(methods: [:active_subscription, :sign_in_count, :recurring_add_ons, :current_active_add_ons])
  end

  def full_name
    if !first_name.blank? && !last_name.blank?
      "#{first_name} #{last_name}"
    elsif !first_name.blank?
      first_name
    elsif !last_name.blank?
      last_name
    else
      "Robin8"
    end
  end

  def can_export
    user_product = self.active_subscription
    return false if user_product.blank?
    ["enterprise-monthly", "enterprise-annual", "ultra-monthly", "ultra-annual", "newenterprise-monthly"].include? user_product.product.slug
  end

  def self.check_mobile_number mobile_number
    return self.where("mobile_number" => mobile_number).present?
  end

  def email_required?
    false
  end

  def email_changed?
    false
  end

  def self.find_user_by_token(token)   #扫码登录通过token查找user
    find($redis.get(token))
  end

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions.to_hash).where(["mobile_number = :value OR lower(email) = :value", { :value => login.downcase }]).first
    elsif conditions.has_key?(:mobile_number) || conditions.has_key?(:email)
      where(conditions.to_hash).first
    end
  end

  def init_appid
    self.update_column(:appid, SecureRandom.hex) if self.appid.blank?
    self.appid
  end

  private

    def needed_user
      is_primary? ? self : self.invited_by
    end
end
