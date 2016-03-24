class Kol < ActiveRecord::Base
  include Redis::Objects
  # counter :redis_new_income      #unit is cent
  list :read_message_ids, :maxlength => 2000             # 所有阅读过的
  list :list_message_ids, :maxlength => 2000             # 所有发送给部分人消息ids
  list :receive_campaign_ids, :maxlength => 2000             # 用户收到的所有campaign 邀请(待接收)
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

  has_many :kol_tags
  has_many :tags, :through => :kol_tags
  has_many :campaign_actions
  has_many :campaign_shows
  has_many :like_campaigns, ->{where(:action => 'like')}, :class => CampaignAction
  has_many :hide_campaigns, ->{where(:action => 'hide')}, :class => CampaignAction
  # has_many :like_campaigns, ->{where(:like => true)}, :through => :campaign_likes, :source => 'campaign'
  # has_many :hide_campaigns, -> {where(:hide => true)}, :through => :campaign_likes, :source => 'campaign'

  has_many :transactions, ->{order('created_at desc')}, :as => :account
  has_many :income_transactions, -> {where(:direct => 'income')}, :as => :account, :class => Transaction
  has_many :withdraw_transactions, -> {where(:direct => 'payout')}, :as => :account, :class => Transaction

  has_many :unread_income_messages, ->{where(:is_read => false, :message_type => 'income')}, :as => :receiver, :class => Message

  after_create :create_campaign_invites_after_signup
  after_save :update_click_threshold

  mount_uploader :avatar, ImageUploader

  has_many :withdraws
  has_many :article_actions



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

  def total_income
    self.income_transactions.sum(:credits)
  end

  def total_withdraw
    self.withdraw_transactions.sum(:credits)
  end

  def verifying_income
    income = 0
    self.campaign_invites.verifying_or_approved.includes(:campaign).each do |invite|
      if invite.campaign &&  invite.campaign.per_action_budget
        if invite.campaign.is_post_type?
          income += invite.campaign.per_action_budget
        else
          income += invite.campaign.per_action_budget * invite.get_avail_click  rescue 0
        end
      end
    end
    income
  end

  def today_income
    income_by_date(Date.today)
  end

  def income_by_date(date)
    post_campaign_income(date) +  click_or_action_campaign_income(date)
  end

  def campaign_count_by_date(date)
    self.campaign_invites.not_rejected.joins(:campaign).where("campaign_invites.approved_at > '#{date.beginning_of_day}'")
        .where("campaigns.actual_deadline_time is null or campaigns.actual_deadline_time < '#{date.end_of_day}'").count
  end

  def post_campaign_income(date)
    income = 0
    self.campaign_invites.not_rejected.approved_by_date(date).includes(:campaign).each do |invite|
      income += invite.campaign.per_action_budget if (invite.campaign && invite.campaign.per_action_budget && invite.campaign.is_post_type?  )
    end
    income
  end

  def click_or_action_campaign_income(date)
    income = 0
    today_show_hash = {}
    self.campaign_shows.by_date(date).valid.group(:campaign_id).select("campaign_id, count(*) as count").each do |show|
      today_show_hash["#{show.campaign_id}"] = show.count
    end
    puts today_show_hash
    self.campaign_invites.not_rejected.includes(:campaign).each do |invite|
      income += invite.campaign.per_action_budget * today_show_hash["#{invite.campaign.id}"]  rescue 0  if !invite.campaign.is_post_type?
    end
    income
  end


  # 最近7天的收入情况
  def recent_income
    _start = Date.today - 6.days
    _end = Date.today
    _recent_income = []
    (_start.._end).to_a.each do |date|
      stats= {:date => date, :total_amount => income_by_date(date), :count => campaign_count_by_date(date)  }
      _recent_income <<  stats
    end
    _recent_income
  end

  def app_city_label
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

    # 重置 invite 收入
    if message.message_type == 'income'
      message.item.reset_new_income  if message.item
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
    kol_id = self.id
    list_message_ids = self.list_message_ids.values.size == 0 ? "''" : self.list_message_ids.values.join(',')
    sql = "select * from messages
           where (
                   (messages.receiver_type = 'Kol' and messages.receiver_id = '#{kol_id}')  or
                   (messages.receiver_type = 'All') or
                   (messages.receiver_type = 'List' and messages.id in (" + list_message_ids + "))
                 )  and
                 messages.created_at > '#{self.created_at}'
                 order by messages.created_at desc "
    Message.find_by_sql sql
  end

  #所有未读消息
  def unread_messages
    kol_id = self.id
    list_unread_message_ids = self.list_message_ids.values - self.read_message_ids.values
    list_unread_message_ids = list_unread_message_ids.size == 0 ? "''" : list_unread_message_ids.join(",")
    read_message_ids = self.read_message_ids.values.size == 0 ? "''" : self.read_message_ids.values.join(",")
    sql = "select * from messages
           where (
                   (messages.receiver_type = 'Kol' and messages.receiver_id = '#{kol_id}' and messages.is_read = '0' )  or
                   (messages.receiver_type = 'All' and messages.id not in (" + read_message_ids + ")) or
                   (messages.receiver_type = 'List' and messages.id in (" + list_unread_message_ids + "))
                 ) and
                 messages.created_at > '#{self.created_at}'
           order by messages.created_at desc "
    Message.find_by_sql sql
  end

  #所有已读消息
  def read_messages
    kol_id = self.id
    read_message_ids = self.read_message_ids.values.size == 0 ? "''" : self.read_message_ids.values.join(",")
    sql = "select * from messages
           where (
                   (messages.receiver_type = 'Kol' and messages.receiver_id = '#{kol_id}' and messages.is_read = '1' )  or
                   (messages.id in (" + read_message_ids + "))
                 ) and
                 messages.created_at > '#{self.created_at}'
           order by messages.created_at desc "
    Message.find_by_sql sql
  end

  #当前用户新收入总计
  def new_income
    income_campaign_invite_ids = unread_income_messages.collect{|message| message.item_id}
    total_income = CampaignInvite.where(:id => income_campaign_invite_ids).inject(0){|sum,i| sum + i.redis_new_income.value }
    total_income / 100
  end

  def add_campaign_id(campaign_id, valid = true)
    if valid
      self.receive_campaign_ids << campaign_id unless self.receive_campaign_ids.include? campaign_id.to_s
    else
      self.receive_campaign_ids << campaign_id
    end
  end

  def delete_campaign_id(campaign_id)
    self.receive_campaign_ids.delete(campaign_id)
  end

  # 成功接收接收活动for pc
  def approve_campaign(campaign_id)
    campaign = Campaign.find campaign_id  rescue nil
    return if campaign.blank? || campaign.status != 'executing'  || !(self.receive_campaign_ids.include? "#{campaign_id}")
    campaign_invite = CampaignInvite.find_or_initialize_by(:campaign_id => campaign_id, :kol_id => self.id)
    if (campaign_invite && campaign_invite.status == 'running')  || campaign_invite.new_record?
      uuid = Base64.encode64({:campaign_id => campaign_id, :kol_id => self.id}.to_json).gsub("\n","")
      campaign_invite.approved_at = Time.now
      campaign_invite.status = 'approved'
      campaign_invite.img_status = 'pending'
      campaign_invite.uuid = uuid
      campaign_invite.share_url = CampaignInvite.generate_share_url(uuid)
      Rails.logger.error "----------share_url:-----#{campaign_invite.share_url}"
      campaign_invite.save
    end
    campaign_invite
  end


  #拆开 approve_campaign 先创建，再接收
  def receive_campaign(campaign_id)
    campaign = Campaign.find campaign_id  rescue nil
    return if campaign.blank? || campaign.status != 'executing'  || !(self.receive_campaign_ids.include? "#{campaign_id}")
    campaign_invite = CampaignInvite.find_or_initialize_by(:campaign_id => campaign_id, :kol_id => self.id)
    if (campaign_invite && campaign_invite.status == 'running')  || campaign_invite.new_record?
      uuid = Base64.encode64({:campaign_id => campaign_id, :kol_id => self.id}.to_json).gsub("\n","")
      campaign_invite.status = 'running'
      campaign_invite.img_status = 'pending'
      campaign_invite.uuid = uuid
      campaign_invite.share_url = CampaignInvite.generate_share_url(uuid)
      campaign_invite.save
    end
    campaign_invite
  end


  # 成功转发活动
  def share_campaign_invite(campaign_invite_id)
    campaign_invite = CampaignInvite.find campaign_invite_id  rescue nil
    if campaign_invite && campaign_invite.status == 'running'
      campaign_invite.status = 'approved'
      campaign_invite.approved_at = Time.now
      campaign_invite.save
      campaign_invite.bring_income(campaign_invite.campaign,true)    if campaign_invite.campaign.is_post_type?
      campaign_invite.reload
    else
      nil
    end
  end

  # 待接收活动列表
  def running_campaigns
    approved_campaign_ids = CampaignInvite.where(:kol_id => self.id).where("status != 'running'").collect{|t| t.campaign_id}
    unapproved_campaign_ids = self.receive_campaign_ids.values.map(&:to_i) -  approved_campaign_ids
    campaigns = Campaign.where(:id => unapproved_campaign_ids).where(:status => 'executing')
    campaigns
  end

  # 已错过的活动       活动状态为finished \settled  且没接
  def missed_campaigns
    approved_campaign_ids = CampaignInvite.where(:kol_id => self.id).where("status != 'running'").collect{|t| t.campaign_id}
    unapproved_campaign_ids = self.receive_campaign_ids.values.map(&:to_i) -  approved_campaign_ids
    Campaign.completed.where(:id => unapproved_campaign_ids)
  end

  def self.reg_or_sign_in(params)
    kol = Kol.find_by(mobile_number: params[:mobile_number])
    if kol.present?
      kol.update_attributes(app_platform: params[:app_platform], app_version: params[:app_version],
                            device_token: params[:device_token], IMEI: params[:IMEI], IDFA: params[:IDFA])
    else
      kol = Kol.create!(mobile_number: params[:mobile_number],  app_platform: params[:app_platform],
                        app_version: params[:app_version], device_token: params[:device_token],
                        IMEI: params[:IMEI], IDFA: params[:IDFA], name: params[:mobile_number],
                        utm_source: params[:utm_source])
    end
    return kol
  end

  def update_influence_result(kol_uuid, influence_score)
    self.update_column(:influence_score, influence_score)
    self.update_column(:kol_uuid, kol_uuid)
  end

  #用户测试价值后注册，此时需要把之前绑定的信息移到正式表中
  def create_info_from_test_influence(kol_uuid)
    Rails.logger.info "--create_info_from_test_influence---#{kol_uuid}---"
    return if kol_uuid.blank?
    ActiveRecord::Base.transaction do
      kol_id = self.id
      kol_value = KolInfluenceValue.find_by :kol_uuid => kol_uuid
      #sync score
      self.update_column(:cal_time, kol_value.updated_at)                if    kol_value
      # sync contacts
      if !self.has_contacts
        KolContact.where(:kol_id => kol_id).delete_all
        TmpKolContact.where(:kol_uuid => kol_uuid).each do |tmp_contact|
          contact = KolContact.new(:kol_id => kol_id, :mobile => tmp_contact.mobile, :name => tmp_contact.name, :exist => tmp_contact.exist,
                                    :invite_status => tmp_contact.invite_status, :invite_at =>  tmp_contact.invite_at)
          contact.save(:validate => false)
        end
      end

      # sync identity
      TmpIdentity.where(:kol_uuid => kol_uuid).each do |tmp_identity|
        identity = Identity.find_by :uid => tmp_identity.uid
        if !identity
          identity = Identity.new
          attrs = tmp_identity.attributes
          attrs.delete("id")
          attrs.delete("kol_uuid")
          identity.attributes = attrs
          identity.kol_id = kol_id
          identity.save
        end
      end
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
      tmp_uids = TmpIdentity.where(:kol_uuid => kol_uuid).collect{|t| t.uid }      rescue []
      new_uids = self.identities.collect{|t| t.uid }           rescue []
      Identity.where(:uid => new_uids - tmp_uids).each do |identity|
        tmp_identity = TmpIdentity.new(:provider => identity.provider, :uid => identity.uid, :name => identity.name,
                                       :avatar_url => identity.avatar_url, :verified => identity.verified, :registered_at => identity.registered_at,
                                       score: identity.score, followers_count: identity.followers_count,  friends_count: identity.friends_count,
                                       statuses_count: identity.statuses_count, kol_uuid:  kol_uuid)
        tmp_identity.save
      end

    end
  end

  def has_contacts
    KolContact.where(:kol_id => self.id).count > 0
  end

end
