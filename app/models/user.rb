class User < ActiveRecord::Base
  include Concerns::PayTransaction

  include Users::AlipayHelper
  include Users::PromotionHelper
  include Users::InvoiceHelper
  attr_accessor :login, :open_token

  has_many :transactions, :as => :account
  has_many :alipay_orders
  has_many :alipay_orders_from_app, -> { where(recharge_from: "app") }, class_name: "AlipayOrder"
  has_many :alipay_orders_from_pc, -> { where(recharge_from: nil) }, class_name: "AlipayOrder"
  has_many  :invoices
  has_one  :invoice_receiver
  has_many :invoice_histories
  belongs_to  :seller, class_name: "Crm::Seller"

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, #:validatable, :confirmable,
         :invitable, :authentication_keys => [:login]

  has_many :identities, dependent: :destroy

  has_many :kols_lists, dependent: :destroy
  has_many :contacts, through: :media_lists

  has_many :campaigns, -> {where.not(status: 'revoked')}
  has_one  :last_campaign, -> {where.not(status: 'revoked').order("created_at DESC") }, class_name: "Campaign"
  has_many :campaign_invites, through: :campaigns

  has_many :article_comments, as: :sender

  has_many :private_kols
  has_many :kols, through: :private_kols
  has_many :paid_transactions, -> {income_or_payout_transaction}, class_name: 'Transaction', as: :account
  has_many :recharge_transactions, -> {recharge_transaction}, class_name: 'Transaction', as: :account
  has_many :campaign_payout_transactions, -> {payout_transaction_of_user_campaign}, class_name: 'Transaction', as: :account
  has_many :campaign_income_transactions, -> {income_transaction_of_user_campaign}, class_name: 'Transaction', as: :account
  belongs_to :kol, inverse_of: :user
  has_many :credits, as: :owner

  has_many :creations


  delegate :e_wallet_account , to: :kol


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

  ransacker :avail_amount do |parent|
    Arel.sql('(`users`.`amount` - `users`.`frozen_amount`)')
  end

  scope :is_live, -> { where(is_live: true) }
  # scope :total_recharge_of_transactions, -> { joins("LEFT JOIN (SELECT `transactions`.`account_id` AS user_id, SUM(`transactions`.`credits`) AS total_recharge FROM `transactions` WHERE `transactions`.`account_type` = 'User' AND (`transactions`.`subject` = 'manual_recharge' OR `transactions`.`subject` = 'alipay_recharge' OR `transactions`.`subject` = 'campaign_pay_by_alipay') GROUP BY `transactions`.`account_id`) AS `cte_tables` ON `users`.`id` = `cte_tables`.`user_id`") }
  # scope :sort_by_total_recharge, ->(dir) { total_recharge_of_transactions.order("total_recharge #{dir}") }

  scope :last_campaigns, -> { joins("LEFT JOIN (SELECT `campaigns`.`user_id` AS user_id, MAX(`campaigns`.`created_at`) AS last_campaign_at FROM `campaigns` WHERE `campaigns`.`status` <> 'revoked' GROUP BY `campaigns`.`user_id`) AS `cte_tables` ON `users`.`id` = `cte_tables`.`user_id`").distinct("user_id") }
  scope :sort_by_last_campaign_at, ->(dir) { last_campaigns.order("last_campaign_at #{dir}") }

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

  def smart_name
    self.name.presence || self.kol.try(:name)
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

  # must be the same as historical_payout attribute
  def total_historical_payout
    self.campaign_payout_transactions.sum(:credits) - self.campaign_income_transactions.sum(:credits)
  end

  def total_recharge
    self.recharge_transactions.sum(:credits)
  end

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions.to_hash).where(["mobile_number = :value OR lower(email) = :value", { :value => login.downcase }]).first
    elsif conditions.has_key?(:mobile_number) || conditions.has_key?(:email)
      where(conditions.to_hash).first
    end
  end

  def self.ransortable_attributes(auth_object = nil)
    ransackable_attributes(auth_object) + %w( sort_by_last_campaign_at )
  end

  def init_appid
    self.update_column(:appid, SecureRandom.hex) if self.appid.blank?
    self.appid
  end

  def credit_amount
    credits.completed.first.try(:amount).to_i
  end

  def credit_expired_at
    credits.completed.first.try(:show_expired_at)
  end

  def credit_expired
    credits.completed.first.try(:expired_at)
  end

  def invalid_credit
    if credit_amount > 0 && credit_expired < Time.now
      Credit.gen_record('expire', 1, -credit_amount, self, nil, credit_expired, "已于 #{credit_expired} 失效")
    end
  end

  private

    def needed_user
      is_primary? ? self : self.invited_by
    end
end
