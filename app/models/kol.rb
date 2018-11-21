# coding: utf-8
class Kol < ActiveRecord::Base
  include Redis::Objects
  # kol_role:  %w{public big_v mcn_big_v mcn}
  # role_apply_status %w{pending applying passed rejected}
  # since 2018-10-24
  # kol_role: [public, big_v, creator]
  # default: pending, when kol apply big_v, creator, role_apply_status = 'applying'


  # counter :redis_new_income      #unit is cent

  counter :registered_invitation_count
  list :read_message_ids, :maxlength => 200            # 所有阅读过的
  list :list_message_ids, :maxlength => 200             # 所有发送给部分人消息ids
  list :receive_campaign_ids, :maxlength => 2000             # 用户收到的所有campaign 邀请(待接收)
  set :invited_users
  
  # elastic_article_kol_detail
  counter :redis_elastic_reads_count
  counter :redis_elastic_collects_count
  counter :redis_elastic_forwards_count
  counter :redis_elastic_likes_count
  counter :redis_elastic_stay_time

  # announcement click counter
  counter :redis_announcement_clicks_count

  include Concerns::PayTransaction
  include Concerns::Unionability
  include Concerns::KolCampaign
  include Concerns::KolTask
  include Kols::BrandUserHelper
  include Kols::StatisticHelper

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

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

  has_many :kol_tags
  has_many :tags, :through => :kol_tags
  has_many :campaign_actions
  has_many :campaign_shows

  has_many :transactions, ->{order('created_at desc')}, :as => :account
  has_many :income_transactions,   -> {income_transaction}, :as => :account, :class => Transaction
  has_many :withdraw_transactions, -> {withdraw_transaction}, :as => :account, :class => Transaction
  has_many :expense_transactions, -> {expense_transaction}, :as => :account, :class => Transaction
  has_many :unread_income_messages, ->{where(:is_read => false, :message_type => 'income')}, :as => :receiver, :class => Message

  after_create :create_campaign_invites_after_signup
  after_save :update_click_threshold, :send_to_be_big_v_notify

  mount_uploader :avatar, ImageUploader

  has_many :withdraws
  has_many :article_actions
  has_many :analysis_identities
  has_many :kol_identity_prices

  has_one  :address, as: :addressable
  has_one :user

  has_many :feedbacks

  has_many :lottery_activity_orders
  has_many :paied_lottery_activity_orders, -> {where("lottery_activity_orders.status != 'pending'")}, :class => LotteryActivityOrder
  has_many :lottery_activities, -> { distinct }, through: :paied_lottery_activity_orders

  has_many :kol_shows
  has_many :images, :source => :referable
  has_many :cover_images, -> {where(:sub_type => 'cover')}, :class => Image, :source => :referable
  has_many :social_accounts, -> {order("case provider when 'weibo' then 5 when 'meipai' then 4 when 'public_wechat' then 3 else 2 end desc")}
  has_many :agent_kols, :foreign_key => :agent_id
  has_many :big_vs, :through => :agent_kols, :source => :kol
  has_one :agent_kol, :foreign_key => :kol_id
  has_one :agent, :through => :agent_kol,  :source => :agent

  has_many :followships, :foreign_key => :kol_id
  has_many :followers, through: :followships,  :source => :follower

  has_many :friendships, :foreign_key => :follower_id, :class_name => 'Followship'
  has_many :friends, through: :friendships, :source => :kol


  has_many :kol_keywords

  #社团
  has_one :club
  # belongs_to :club_member
  has_one :club_member
  # has_and_belongs_to_many :clubs
  #内容创造者
  has_one :creator
  #big_v
  has_one :weibo_account
  has_one :public_wechat_account

  # vote
  has_many :voter_ships, ->{order('count desc')}
  has_many :voters, through: :voter_ships, source: :voter
  has_many :votes


  # evan new big_v
  def is_new_big_v?
    weibo_account.try(:status) == 1 || public_wechat_account.try(:status) == 1
  end

  def big_v
    self.weibo_account.present? ? weibo_account : public_wechat_account
  end


  # PK's
  has_many :received_challenges, class_name: "KolPk", foreign_key: "challengee_id", inverse_of: :challenger
  has_many :sent_challenges,     class_name: "KolPk", foreign_key: "challenger_id", inverse_of: :challengee

  # ElasticArticle
  has_many :elastic_article_actions

  has_many :announcement_shows
  has_one :e_wallet_account, class_name: "EWallet::Account"
  has_many :e_wallet_transtions, class_name: "EWallet::Transtion"

  #cirlces 
  has_many :kols_circles, class_name: "KolsCircle"
  has_many :circles, through: :kols_circles

  def challenges
    KolPk.where("challenger_id = ? or challengee_id = ?", id, id)
  end

  def won_challenges
    KolPk.where("(challenger_id = ? and challenger_score > challengee_score) or "+
                "(challengee_id = ? and challengee_score > challenger_score)",id,id)
  end

  def lost_challenges
    KolPk.where("(challenger_id = ? and challengee_score > challenger_score) or "+
                "(challengee_id = ? and challenger_score > challengee_score)",id,id)
  end

  #cps
  has_many :cps_articles
  has_many :cps_article_shares
  has_many :cps_promotion_orders do
    def cps_promotion_order_items
      cps_promotion_order_ids = proxy_association.select(:id)
      CpsPromotionOrderItem.where(cps_promotion_order_id: cps_promotion_order_ids)
    end
  end

  has_one  :registered_invitation,  foreign_key: :invitee_id, inverse_of: :invitee
  has_many :registered_invitations, foreign_key: :inviter_id, inverse_of: :inviter

  # Admin tags
  has_and_belongs_to_many :admintags

  has_many :influence_metrics

  has_one :kol_invite_code

  # add kol admin
  belongs_to :admin,    class_name: 'Kol', foreign_key: :admin_id
  has_many   :leaguers, class_name: 'Kol', foreign_key: :admin_id

  #scope :active, -> {where("`kols`.`updated_at` > '#{3.months.ago}'").where("kol_role='mcn_big_v' or device_token is not null")}
  scope :ios, ->{ where("app_platform = 'IOS'") }
  scope :android, ->{ where("app_platform = 'Android'") }
  scope :by_date, ->(date){where("created_at > '#{date.beginning_of_day}' and created_at < '#{date.end_of_day}' ") }
  scope :order_by_hot, ->{order("is_hot desc, role_apply_time desc, id desc")}
  scope :order_by_created, ->{order("created_at desc")}
  if Rails.env.production?
    scope :active, -> {where("`kols`.`updated_at` > '#{3.months.ago}' and `kols`.`mobile_number` is not null")} #.where("kol_role='mcn_big_v' or device_token is not null")}
    scope :big_v, ->{ }
    # scope :mcn_big_v, -> { }
    scope :personal_big_v, ->{ }
  else
    scope :active, -> {where("`kols`.`updated_at` > '#{3.months.ago}' and `kols`.`mobile_number` is not null")}
    scope :big_v, ->{ where("kol_role = 'mcn_big_v' or kol_role = 'big_v'") }
    # scope :mcn_big_v, -> {where("kol_role = 'mcn_big_v'")}
    scope :personal_big_v, -> {where("kol_role = 'big_v'")}
  end
  # Push message will send it only to users with 'device_token' (who are also fulfilling other params set in campaign: age, etc.)
  scope :campaign_message_suitable, -> { where("`kols`.`updated_at` > '#{12.months.ago}'") }

  scope :recent, ->(_start,_end){ where(created_at: _start.beginning_of_day.._end.end_of_day) }
  
  scope :admintag, ->(admintag) { joins(:admintags).where("admintags.tag=?", admintag) }

  AdminKolIds = [79,48587]
  TouristMobileNumber = "13000000000"

  ransacker :avail_amount do |parent|
    Arel.sql('(`kols`.`amount` - `kols`.`frozen_amount`)')
  end

  # scope :total_income_of_transactions, -> { joins("LEFT JOIN (SELECT `transactions`.`account_id` AS kol_id, SUM(`transactions`.`credits`) AS total_income FROM `transactions` WHERE `transactions`.`account_type` = 'Kol' AND `transactions`.`direct` = 'income' GROUP BY `transactions`.`account_id`) AS `cte_tables` ON `kols`.`id` = `cte_tables`.`kol_id`") }
  # scope :sort_by_total_income, ->(dir) { total_income_of_transactions.order("total_income #{dir}") }

  before_save :set_kol_kol_role

  def set_kol_kol_role
    #role_apply_status %w{pending applying passed rejected}
    #kol_role:  %w{public big_v mcn_big_v mcn}
    if role_apply_status_changed?
      if role_apply_status == "passed" and (self.kol_role == "public" or self.kol_role.blank?)
        self.kol_role = 'big_v'
      end

      if role_apply_status == "rejected"
        if self.kol_role == "big_v"
          self.kol_role = "public"
        end
      end
    end
  end

  # 师徒弟关系 evan 2018.3.16
  def parent
    registered_invitation.try(:inviter)
  end

  def children
    Kol.where(id: registered_invitations.completed.collect{|ri| ri.invitee_id})
  end
  # end evan 2018.3.16


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

  def avatar_url
    if self.attributes["avatar"] and (self.attributes["avatar"].start_with?("http") or self.attributes["avatar"].start_with?("https"))
      return self.attributes["avatar"]
    end
    return self.avatar.url
  end

  def self.check_mobile_number mobile_number
    return Kol.where("mobile_number" => mobile_number).present?
  end

  def active
    not confirmed_at.nil?
  end

  def safe_name
    return self.name if /(^(13\d|15[^4,\D]|17[13678]|18\d)\d{8}|170[^346,\D]\d{7})$/.match(self.name).blank?

    self.name[0, 3] + "*" * 4 + self.name[7, 4]
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

  def identity_score(provider)
    (self.identities.provider(provider).collect{|t| t.score}.max  || 0  )
  end

  def create_campaign_invites_after_signup
    # CampaignSyncAfterSignup.perform_async(self.id)
    self.sync_campaigns
  end

  def self.fetch_kol_with_level(kol_id)
    Rails.cache.fetch("kol_#{kol_id}", :expires_in => 1.days) do
      Kol.find(kol_id)
    end    rescue nil
  end

  def update_click_threshold
    if five_click_threshold_changed? || kol_level_changed?
      Rails.cache.delete("kol_#{self.id}")
    end
  end

  def has_pending_withdraw
    withdraws.pending.size > 0
  end

  def reset_private_token
    self.update_column(:private_token, SecureRandom.hex)
  end

  def get_private_token
    self.reset_private_token  if !self.private_token
    self.private_token
  end

  def get_issue_token
    AuthToken.issue_token(get_private_token)
  end

  def self.app_auth(private_token)
    Kol.find_by :private_token => private_token    rescue nil
  end

  def verifying_income
    income = 0
    self.campaign_invites.verifying_or_approved.includes(:campaign).each do |invite|
      if invite.campaign &&  invite.campaign.actual_per_action_budget
        if invite.campaign.is_post_type? || invite.campaign.is_simple_cpi_type? || invite.campaign.is_recruit_type? || invite.campaign.is_cpt_type?
          income += invite.campaign.actual_per_action_budget
        else
          income += invite.campaign.actual_per_action_budget * invite.get_avail_click  rescue 0
        end
      end
    end
    income
  end

  def today_income
    income, count = income_by_date(Date.today)
    income
  end

  def income_by_date(date)
    count_income, count_count = post_or_recruit_campaign_income(date)
    sum_income, sum_count = click_or_action_campaign_income(date)
    task_income, task_count = task_income(date)
    income =  count_income + sum_income +  task_income
    count = count_count + sum_count +  task_count
    [income, count]
  end

  # def campaign_count_by_date(date)
  #   self.campaign_invites.not_rejected.joins(:campaign).where("campaign_invites.approved_at < '#{date.end_of_day}'")
  #       .where("campaigns.actual_deadline_time is null or campaigns.actual_deadline_time > '#{date.beginning_of_day}'").count
  # end

  def post_or_recruit_campaign_income(date)
    income = 0
    count = 0
    self.campaign_invites.not_rejected.approved_by_date(date).includes(:campaign).each do |invite|
      if invite.campaign && invite.campaign.actual_per_action_budget && (invite.campaign.is_post_type? || invite.campaign.is_simple_cpi_type? || invite.campaign.is_recruit_type? || invite.campaign.is_cpt_type?)
        income += invite.campaign.actual_per_action_budget
        count += 1
      elsif invite.campaign.is_invite_type?
        income += invite.price
        count += 1
      end
    end
    [income, count]
  end

  def task_income(date)
    income = self.transactions.recent(date,date).realtime_transaction.sum(:credits)
    count = self.transactions.recent(date,date).realtime_transaction.count
    [income,count]
  end


  def click_or_action_campaign_income(date)
    income = 0
    count = 0
    today_show_hash = {}
    show_campaign_ids = []
    self.campaign_shows.by_date(date).valid.group(:campaign_id).select("campaign_id, count(*) as count").each do |show|
      if show.count > 0
        today_show_hash["#{show.campaign_id}"] = show.count
        show_campaign_ids << show.campaign_id
      end
    end
    puts today_show_hash
    self.campaign_invites.not_rejected.where(:campaign_id => show_campaign_ids).includes(:campaign).each do |invite|
      if invite.campaign.is_click_type? || invite.campaign.is_cpa_type? ||  invite.campaign.is_cpi_type?
        income += invite.campaign.actual_per_action_budget * today_show_hash["#{invite.campaign.id}"]  rescue 0
        count += 1
      end
    end
    [income, count]
  end
  
  # 計算邀請朋有收入
  def inv_frd_income(date)
    [
      transactions.recent(date, date).subjects('invite_friend').sum(:credits),
      transactions.recent(date, date).subjects('invite_friend').count
    ]
  end

  # 最近7天的收入情况
  def recent_income
    _start = Date.today - 6.days
    _end = Date.today
    _recent_income = []

    (_start.._end).to_a.each do |date|
      income, count = income_by_date(date)
      stats= {:date => date, :total_amount => income, :count => count  }
      _recent_income <<  stats
    end
    _recent_income
  end

  def recent_7_income
    _array = []
    DateTimeExtend.sequence(6.days.ago.beginning_of_day, Date.today.end_of_day, 1.day).each do |time|
      trs = transactions.income_transaction.recent(time, time)
      _array << {date: time.strftime('%F'), total_amount: trs.sum(:credits), count: trs.count}
    end
    _array
  end

  def app_city_label
    return nil if self.app_city.blank?
    City.find_by(:name_en => app_city).name rescue nil
  end

  def read_message(message_id)
    message = Message.find message_id
    return if message.blank?
    message.read_at = Time.now
    message.is_read = true
    message.save

    # 记录到 read_meesage_ids
    self.read_message_ids << message_id unless  self.read_message_ids.include? message_id.to_s
  end

  def read_all
    unread_message_ids = self.unread_messages.collect{|t| t.id.to_s}
    Message.where(:id => unread_message_ids).update_all(:read_at => Time.now, :is_read => true)
    unread_message_ids.each do |message_id|
      self.read_message_ids << message_id   unless self.read_message_ids.include?(message_id)
    end
  end

  def message_status(message)
    if message.receiver_type == 'Kol'
      message.is_read
    else
      self.read_message_ids.include? message.id.to_s
    end
  end

  #所有消息
  def messages
    all_messages = Message.where("created_at > '#{self.created_at}' and receiver_type='All'")

    list_message_ids_values = self.list_message_ids.values
    if list_message_ids_values.size == 0
      list_messages = []
    else
      list_messages = Message.where("created_at > '#{self.created_at}' and receiver_type='List'")
                        .where(id: list_message_ids_values)
    end

    kol_messages = Message.where(receiver_id: self.id)
                     .where("created_at > '#{self.created_at}' and receiver_type='Kol'")

    (all_messages + list_messages + kol_messages).uniq.sort_by {|i| i.created_at }.reverse
  end

  #所有未读消息
  def unread_messages
    message_limit_at = self.created_at < 10.days.ago ? 10.days.ago :  self.created_at

    list_unread_message_ids = self.list_message_ids.values - self.read_message_ids.values
    if list_unread_message_ids.size == 0
      list_unread_messages = []
    else
      list_unread_messages = Message.where(receiver_type: 'List').where(id: list_unread_message_ids)
                               .where("created_at > '#{message_limit_at}'")
    end

    read_message_ids_values = self.read_message_ids.values
    if read_message_ids_values.size == 0
      all_unread_messages = []
    else
      all_unread_messages = Message.where(receiver_type: 'All').where.not(id: read_message_ids_values)
                              .where("created_at > '#{message_limit_at}'")
    end

    kol_unread_messages = Message.where(receiver_id: self.id).where(receiver_type: 'Kol', is_read: 0)
                            .where("created_at > '#{message_limit_at}'")

    (kol_unread_messages + list_unread_messages + all_unread_messages).uniq.sort_by {|i| i.created_at }.reverse
  end

  #所有已读消息
  def read_messages
    message_limit_at = self.created_at < 10.days.ago ? 10.days.ago :  self.created_at

    read_message_ids_values = self.read_message_ids.values
    if read_message_ids_values.size == 0
      read_messages = []
    else
      read_messages = Message.where(id: read_message_ids_values).where("created_at > '#{message_limit_at}'")
    end

    kol_read_messages = Message.where(receiver_type: 'Kol', receiver_id: self.id, is_read: 1)
                          .where("created_at > '#{message_limit_at}'")

    (read_messages + kol_read_messages).uniq.sort_by {|i| i.created_at }.reverse
  end

  #当前用户新收入总计
  def new_income
    income_campaign_invite_ids = unread_income_messages.collect{|message| message.item_id}
    total_income = CampaignInvite.where(:id => income_campaign_invite_ids).inject(0){|sum,i| sum + i.redis_new_income.value }
    total_income / 100
  end


  def self.reg_or_sign_in(params, kol = nil)
    Rails.logger.info "---reg_or_sign_in --- kol: #{kol} --- params: #{params}"
    kol ||= Kol.find_by(mobile_number: params[:mobile_number])    if params[:mobile_number].present?
    # app_city = City.where("name like '#{params[:city_name]}%'").first.name_en   rescue nil
    # app_city = TaobaoIps.get_detail(params[:current_sign_in_ip])["data"]['city']
    app_city = nil
    if kol.present?
      retries = true
      begin
        kol.update_attributes(app_platform: params[:app_platform], app_version: params[:app_version],
                              device_token: params[:device_token], IMEI: params[:IMEI], IDFA: params[:IDFA],
                              os_version: params[:os_version], device_model: params[:device_model], app_city: app_city,
                              longitude: params[:longitude], latitude: params[:latitude])
      rescue ActiveRecord::StaleObjectError => e
        if retries == true
          retries = false
          kol.reload
          retry
        else
          ::NewRelic::Agent.record_metric('Robin8/Errors/ActiveRecord::StaleObjectError', e)
        end
      end
    else
      _hash = {mobile_number: params[:mobile_number],  app_platform: params[:app_platform],
                        app_version: params[:app_version], device_token: params[:device_token],
                        IMEI: params[:IMEI], IDFA: params[:IDFA],
                        name: (params[:name] || Kol.hide_real_mobile_number(params[:mobile_number])),
                        utm_source: params[:utm_source], app_city: app_city, os_version: params[:os_version],
                        device_model: params[:device_model], current_sign_in_ip: params[:current_sign_in_ip],
                        longitude: params[:longitude], latitude: params[:latitude], avatar_url: params[:avatar_url]}
           
      _hash.merge!({kol_level: 'S', channel: 'geometry'}) if params[:invite_code] == "778888"
      kol = Kol.create!(_hash)
    end
    kol
  end

  def update_influence_result(kol_uuid, influence_score, cal_time = Time.now)
    if  self.influence_score.to_i < influence_score.to_i
      self.update_columns(:influence_score => influence_score, :kol_uuid => kol_uuid, :cal_time => cal_time)
      KolInfluenceValueHistory.where(:kol_uuid => kol_uuid).where("kol_id is null").update_all(:kol_id => self.id)
    end

  end

  #用户测试价值后注册，此时需要把之前绑定的信息移到正式表中
  def create_info_from_test_influence(kol_uuid)
    Rails.logger.info "--create_info_from_test_influence---#{kol_uuid}---"
    return if kol_uuid.blank?
    kol_id = self.id
    # sync contacts
    if !self.has_contacts
      KolContact.where(:kol_id => kol_id).delete_all
      TmpKolContact.where(:kol_uuid => kol_uuid).each do |tmp_contact|
        next if  tmp_contact.mobile.blank?  || tmp_contact.name.blank?   || Influence::Util.is_mobile?(tmp_contact.mobile.to_s).blank?
        contact = KolContact.new(:kol_id => kol_id, :mobile => tmp_contact.mobile, :name => tmp_contact.name, :exist => tmp_contact.exist,
                                 :invite_status => tmp_contact.invite_status, :invite_at =>  tmp_contact.invite_at)
        contact.save!(:validate => false)
      end
    end

    # sync identity
    TmpIdentity.where(:kol_uuid => kol_uuid).each do |tmp_identity|
      identity = Identity.find_or_initialize_by :uid => tmp_identity.uid
      attrs = tmp_identity.attributes
      attrs.delete("id")
      attrs.delete("kol_uuid")
      identity.attributes = attrs
      identity.kol_id = kol_id   if identity.kol_id.blank?
      identity.save!
      # Weibo.update_identity_info(identity)
    end
  end

  def get_kol_uuid
    self.update_column(:kol_uuid, SecureRandom.hex)   if self.kol_uuid.blank?
    self.kol_uuid
  end

  def sync_tmp_identity_from_kol(kol_uuid)
    Rails.logger.info "--create_test_info_from_kol---#{kol_uuid}---"
    return if kol_uuid.blank?
    ActiveRecord::Base.transaction do
      TmpIdentity.where(:kol_uuid => kol_uuid).delete_all
      self.identities.each do |identity|
        tmp_identity = TmpIdentity.new(:provider => identity.provider, :uid => identity.uid, :name => identity.name, :token => identity.token,
                                       :avatar_url => identity.avatar_url, :verified => identity.verified, :registered_at => identity.registered_at,
                                       score: identity.score, followers_count: identity.followers_count,  friends_count: identity.friends_count,
                                       statuses_count: identity.statuses_count, kol_uuid:  kol_uuid, refresh_time: identity.refresh_time,
                                       access_token_refresh_time: identity.access_token_refresh_time, refresh_token: identity.refresh_token)
        tmp_identity.save!
      end

    end
  end

  def has_contacts
    KolContact.where(:kol_id => self.id).count > 0
  end

  def get_rongcloud_token
    RongCloud.get_token self
  end

  def can_update_alipay
    self.alipay_account.blank? || self.id_card.blank? || (self.withdraws.approved.where("created_at > '2016-06-01'").size == 0  &&  self.withdraws.pending.where("created_at > '2016-06-01'").size == 0)
  end

  def address!
    return self.address if self.address
    Address.create.tap { |a| self.update(address: a) }
  end

  #override devise  request.remote_ip is null
  def update_tracked_fields(request)
    self.reload
    return if self.current_sign_in_at.present? && Date.today == self.current_sign_in_at.to_date
    old_current, new_current = self.current_sign_in_at, Time.now.utc
    self.last_sign_in_at     = old_current || new_current
    self.current_sign_in_at  = new_current


    ip = (request.remote_ip rescue nil) || request.ip
    old_current, new_current = self.current_sign_in_ip, ip
    self.last_sign_in_ip     = old_current || new_current
    self.current_sign_in_ip  = new_current

    self.sign_in_count ||= 0
    self.sign_in_count += 1
    begin
      self.save
    rescue ActiveRecord::StaleObjectError => e

    end
  end

  def self.hide_real_mobile_number(mobile_number)
    mobile_number.to_s[0,3] + "****" + mobile_number.to_s[7,4]   rescue mobile_number
  end

  def self.get_official_appid
    if Rails.env.production?
      '5cfed04140924e84de5445642cef531d'
    else
      'xxx'
    end
  end

  # def self.ransortable_attributes(auth_object = nil)
  #   ransackable_attributes(auth_object) + %w( sort_by_total_income )
  # end

  def get_uniq_identities
    self.identities.group("provider")
  end

  def remove_same_device_token(device_token)
    Kol.where(:device_token => device_token).where.not(:id => self.id).update_all(:device_token => nil)
  end

  def get_avatar_url
    avatar.url(:avatar) || read_attribute(:avatar_url)
  end

  def avatar_url
    if self.attributes[:avatar]
      return avatar.url(:avatar)
    end
    get_avatar_url
  end

  def is_big_v?
    self.kol_role == 'big_v' || self.kol_role == 'mcn_big_v'
  end

  def follow(big_v)
    followship = Followship.find_by(:follower_id => self.id, :kol_id => big_v.id)
    if followship
      followship.delete
    else
      Followship.create!(:follower_id => self.id, :kol_id => big_v.id)
    end
  end

  def is_follow?(big_v)
    big_v.followships.collect{|t| t.follower_id}.include?(self.id)
  end

  def gender_text
    case self.gender
      when 1
        "男"
      when 2
        "女"
      else
        "未知"
    end
  end

  BindMaxCount = Rails.env.production? ? 3 : 300
  def self.device_bind_over_3(imei,idfa)
    return false
    # if imei.present?
    #   return Kol.where(:IMEI => imei).where("mobile_number != '#{Kol::TouristMobileNumber}'").size >= BindMaxCount
    # elsif idfa.present?
    #   return Kol.where(:IDFA => idfa).where("mobile_number != '#{Kol::TouristMobileNumber}'").size >= BindMaxCount
    # else
    #   return false
    # end
  end

  def is_forbid?
    self.forbid_campaign_time.present? && self.forbid_campaign_time > Time.now
  end

  def send_to_be_big_v_notify
    if self.kol_role == 'big_v' && self.kol_role_changed?
      content = "恭喜！您的KOL资质审核通过了，速去打开Robin8 APP查看详情！"
      PushMessage.push_common_message([self], content, 'KOL资质审核通过')
      SmsMessage.send_to(self, content)
    end
  end

  def self.get_all_weibo_uids
    identity_uids = Identity.where(:provider => 'weibo').where("uid is not null and uid != ''").collect{|t| t.uid }
    social_uids = SocialAccount.where(:provider => 'weibo').where("uid is not null and uid != ''").collect{|t| t.uid }
    all_uids = (identity_uids + social_uids).uniq
    File.open("#{Rails.root}/tmp/uids.txt", 'wb'){|f| f.write all_uids.join(",")}
    File.open("#{Rails.root}/tmp/uids.yaml", 'wb'){|f| f.write YAML::dump(all_uids) }
    all_uids
  end

  def similar_influence_kol_ids provider='weibo'
    metrics = self.influence_metrics.where(provider: provider)
    return [] unless metrics.any?
    kol_best_industry = metrics.first.influence_industries.order(industry_score: :desc).first
    kol_ids_higher_score = InfluenceIndustry.where(industry_name: kol_best_industry.industry_name)
                                            .where('industry_score > ?', kol_best_industry.industry_score)
                                            .order(industry_score: :desc).limit(8)
                                            .joins(:influence_metric)
                                            .pluck('influence_metrics.kol_id')
    # remove kols who didn't allow to view their influence score
    allowed_kols = Kol.where(id: kol_ids_higher_score).where(influence_score_visibility: [nil, 1]).pluck(:id)

    # remove kol itself from the list
    allowed_kols - [self.id]
  end

  def get_invited_users
    invited_converted_to_kol = Kol.where(mobile_number: self.invited_users.members).pluck(:mobile_number)
    invited_converted_to_kol.each do |existing_kol|
      self.invited_users.delete(existing_kol.to_s)
    end
    self.invited_users.members
  end

  def invite_code_dispose(code)
    code = code.to_s
    if code.size == 8
      invite_code = KolInviteCode.find_by(code: code)
      RegisteredInvitation.create(mobile_number: self.mobile_number , inviter_id: invite_code.kol_id , status: "pending")
      # 受邀请人的admintags赋给受邀人
      self.admintags = invite_code.kol.admintags
      # 如果邀请人是角色是管理员或邀请人管理员存在，than
      self.update_attributes(admin_id: invite_code.kol_id)       if invite_code.kol.role == 'admin'
      self.update_attributes(admin_id: invite_code.kol.admin_id) if invite_code.kol.admin
      true
    elsif code.size == 6
      invite_code = InviteCode.find_by(code: code)
      if invite_code.invite_type == "admintag"
        admintag = Admintag.find_or_create_by(tag: invite_code.invite_value)
        unless self.admintags.include? admintag
          self.admintags << admintag
          self.update_attributes(admin_id: admintag.admin.id) if admintag.admin
          CallbackGeometryWorker.perform_async(self.id) if code == "778888"
        end
      elsif invite_code.invite_type == "club_leader"
        if invite_code.invite_value.present?
          club_name = invite_code.invite_value
        else
          club_name = self.mobile_number
        end
        Club.create(kol_id: self.id , club_name: club_name)
      elsif invite_code.invite_type == "club_number"
        club = Club.find invite_code.invite_value
        ClubMember.create(club_id: club.id , kol_id: self.id)
      end
    end
    true
  end

  def desc_friend_gains
    friend_gains.group(:opposite_id).sum(:credits).sort_by{|_key, value| value}.collect{|ele| ele[0]}.reverse
  end

  def desc_percentage_on_friend
    (desc_friend_gains + children.map(&:id)).uniq   
  end

  def create_invite_code
    begin
      code = [*(0..9)].sample(8).join
      raise "repetitive_invite_code"   unless  InviteCode.create(code: code.to_i , invite_type: 'invite_friend' , invite_value: self.id).valid?
    rescue
      retry
    end
  end

  # def get_share_proportion(credits)
  #   proportion = self.club_number.club.proportion
  #   [proportion * credits , (1 - proportion) * credits]
  # end

  # 业务更改，每个kol接活动的单价都不一样，详情查看app/models/admintag_strategy.rb
  def strategy
    admintags.map(&:admintag_strategy).first.owner_sets rescue AdmintagStrategy::InitHash
  end

  def invite_desc
    if strategy[:tag]
      "每位好友有#{strategy[:invite_bounty]}元额外奖励"
    else
      "每日前10位徒弟有#{strategy[:invite_bounty]}元额外奖励"
    end
  end

  def master_desc
    if strategy[:master_income_rate] > 0
      "徒弟通过活动收入的#{(strategy[:master_income_rate] * 100).to_i}%(收益四舍五入精确到小数点后两位,如0.012为0.01; 0.026为0.03), 收徒越多奖励越多,徒弟总数无上限。"
    else
      ''
    end
  end

  def qr_invite
    qr_url = "#{Rails.application.secrets.domain}/invite?inviter_id=#{id}"
    RQRCode::QRCode.new(qr_url, size: 12, level: :h).as_svg(module_size: 3)
  end

  # 基本信息完成度
  def completed_rate
    ([avatar_url.present?, name.present?, gender.to_i > 0, birthday.present?, job_info.present?, circles.present?, wechat_friends_count > 0, social_accounts.present?, true].count(true).to_f / 9).round(2)
  end

  def set_account_have_read
    _ary= { 1 => [], -1 => [] }

    %w(weibo_account public_wechat_account creator).each do |ele|
      unless self.send(ele).try(:is_read).try(:value) == 0
        _ary[1]  << {state: 1,  dsp: self.send(ele).get_dsp } if self.send(ele).try(:status) == 1
        _ary[-1] << {state: -1, dsp: self.send(ele).get_dsp } if self.send(ele).try(:status) == -1
      end
    end
    _ary.values.flatten
  end

  def vote_ranking
    Kol.count("is_hot > #{is_hot.to_i}").succ
  end

end
