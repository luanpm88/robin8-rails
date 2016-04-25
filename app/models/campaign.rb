class Campaign < ActiveRecord::Base
  include Redis::Objects
  include Concerns::CampaignTest
  counter :redis_avail_click
  counter :redis_total_click
  include Campaigns::CampaignTargetHelper
  include Campaigns::CampaignBaseHelper

  validates_presence_of :name, :description, :url, :budget, :per_budget_type, :per_action_budget, :start_time, :deadline, :if => Proc.new{ |campaign| campaign.per_budget_type != 'recruit' }
  validates_presence_of :name, :description, :task_description, :address, :budget, :per_budget_type, :per_action_budget, :recruit_start_time, :recruit_end_time, :start_time, :deadline, :if => Proc.new{ |campaign| campaign.per_budget_type == 'recruit' }

  #Status : unexecute agreed rejected  executing executed
  #Per_budget_type click post cpa
  # status ['unexecuted', 'agreed','rejected', 'executing','executed','settled']
  belongs_to :user
  has_many :campaign_invites
  # has_many :pending_invites, -> {where(:status => 'pending')}, :class_name => 'CampaignInvite'
  has_many :valid_invites, -> {where("status='approved' or status='finished' or status='settled'")}, :class_name => 'CampaignInvite'
  has_many :valid_applies, -> {where("status='platform_passed' or status='brand_passed' or status='brand_rejected'")}, :class_name => 'CampaignApply'
  has_many :brand_passed_applies, -> {where(status: 'brand_passed')}, :class_name => 'CampaignApply'
  has_many :rejected_invites, -> {where(:status => 'rejected')}, :class_name => 'CampaignInvite'
  has_many :finished_invites, -> {where(:status => 'finished')}, :class_name => 'CampaignInvite'
  has_many :finish_need_check_invites, -> {where(:status => 'finished', :img_status => 'pending')}, :class_name => 'CampaignInvite'
  has_many :passed_invites, -> {where(:status => 'finished', :img_status => 'passed')}, :class_name => 'CampaignInvite'
  has_many :settled_invites, -> {where(:status => 'settled', :img_status => 'passed')}, :class_name => 'CampaignInvite'
  has_many :campaign_shows
  has_many :kols, through: :campaign_invites
  has_many :approved_kols, through: :valid_invites
  has_many :weibo_invites
  has_many :weibo, through: :weibo_invites
  has_many :articles
  has_many :kol_categories, :through => :kols
  has_many :campaign_action_urls, autosave: true

  has_many :campaign_categories
  has_many :iptc_categories, :through => :campaign_categories
  has_many :interested_campaigns
  belongs_to :release
  has_many :campaign_applies

  scope :click_campaigns, -> {where(:per_budget_type => 'click')}
  scope :click_or_action_campaigns, -> {where("per_budget_type = 'click' or per_action_budget = 'cpa'")}
  scope :order_by_start, -> { order('start_time desc')}
  scope :order_by_status, -> { order("case campaigns.status  when 'executing' then 3 when 'executed' then 2 else 1 end desc,
                                      case campaigns.per_budget_type when 'recruit' then 4 else 1 end desc,
                                      start_time desc") }

  scope :completed, -> {where("status = 'executed' or status = 'settled'")}
  after_save :create_job

  OfflineProcess = ["点击立即报名，填写相关资料，完成报名","资质认证通过", "准时参与活动，并配合品牌完成相关活动", "根据品牌要求，完成相关推广任务", "上传任务截图", "任务完成，得到酬金"]
  SettleWaitTimeForKol = Rails.env.production?  ? 1.days  : 1.hours
  SettleWaitTimeForBrand = Rails.env.production?  ? 4.days  : 2.hours
  RemindUploadWaitTime =  Rails.env.production?  ? 3.days  : 1.minutes
  def email
    user.try :email
  end

  def upload_screenshot_deadline
    (self.actual_deadline_time ||self.deadline) +  SettleWaitTimeForBrand
  end

  def can_apply
    self.recruit_start_time < Time.now && Time.now < recruit_end_time
  end

  def is_cpa?
    self.per_budget_type.to_s == "cpa"
  end

  def get_stats
    end_time = ((status == 'executed' || status == 'settled') ? self.deadline : Time.now)
    shows = campaign_shows
    labels = []
    total_clicks = []
    avail_clicks = []
    (start_time.to_date..end_time.to_date).each do |date|
      labels << date.to_s
      total_clicks << shows.by_date(date.to_datetime).count
      avail_clicks << shows.valid.by_date(date.to_datetime).count
    end
    if total_clicks.size == 1
      labels.unshift "活动开始"
      total_clicks.unshift 0
      avail_clicks.unshift 0
    end
    [self.per_budget_type, labels, total_clicks, avail_clicks]
  end

  def need_finish
    self.per_budget_type == 'post' && self.valid_invites.size >= self.max_action && self.status == 'executing'
  end

  #统计信息
  def get_total_by_day
    self.campaign_shows.group("date_format(created_at, 'YYYY-MM-DD') ").select(" date_format(created_at, 'YYYY-MM-DD') as created, count(*) as count ")
  end

  def get_valid_by_day
    self.campaign_shows.valid.group("date_format(created_at, 'YYYY-MM-DD') ").select(" date_format(created_at, 'YYYY-MM-DD') as created, count(*) as count ")
  end

  def get_avail_click
    self.redis_avail_click.value      rescue self.avail_click
  end

  def get_total_click
    self.redis_total_click.value   rescue self.total_click
  end

  def get_fee_info
    "#{self.take_budget} / #{self.budget}"
  end

  def take_budget
    if self.is_click_type? or self.is_cpa?
      if self.status == 'settled'
        (self.settled_invites.sum(:avail_click) * self.per_action_budget).round(2)       rescue 0
      else
        (get_avail_click * self.per_action_budget).round(2)       rescue 0
      end
    else
      if self.status == 'settled'
        (self.settled_invites.count * self.per_action_budget).round(2) rescue 0
      else
        (self.valid_invites.count * self.per_action_budget).round(2) rescue 0
      end
    end
  end

  def remain_budget
    return (self.budget - self.take_budget).round(2)
  end

  def post_count
    if self.per_budget_type == "click" or self.is_cpa?
      return -1
    end
    return valid_invites.count
  end

  def join_count
    valid_invites.count
  end

  def get_share_time
    return 0 if status == 'unexecute'
    self.valid_invites.size
  end
  alias_method :share_times, :get_share_time


  # 开始时候就发送邀请 但是状态为pending
  def send_invites(kol_ids = nil)
    _start = Time.now
    Rails.logger.campaign_sidekiq.info "---send_invites: cid:#{self.id}--campaign status: #{self.status}---#{self.deadline}----kol_ids:#{kol_ids}-"
    return if self.status != 'agreed'
    self.update_attribute(:status, 'rejected') && return if self.deadline < Time.now
    Rails.logger.campaign_sidekiq.info "---send_invites: -----cid:#{self.id}--start create--"
    campaign_id = self.id
    kol_ids = get_specified_kol_ids
    if kol_ids.present?
      Kol.where(:id => kol_ids).each do |kol|
        kol.add_campaign_id campaign_id
      end
    else
      #TODO multi-thread deal
      Kol.find_each do |kol|
        kol.add_campaign_id(campaign_id,false)
      end
    end
    unmatched_kol_ids = get_unmatched_kol_ids
    Kol.where(:id => unmatched_kol_ids).each do |kol|
      kol.delete_campaign_id campaign_id
    end
    Rails.logger.campaign_sidekiq.info "---send_invites: ---cid:#{self.id}--campaign unmatched_kol_ids: ---#{unmatched_kol_ids}-"
    # make sure those execute late (after invite create)
    #招募类型 在报名开始时间 就要开始发送活动邀请 ,且在真正开始时间  需要把所有未通过的设置为审核失败
    if  is_recruit_type?
      _start_time = self.recruit_start_time < Time.now ? (Time.now + 5.seconds) : self.recruit_start_time
      CampaignWorker.perform_at(_start_time, self.id, 'start')
      CampaignWorker.perform_at(self.start_time, self.id, 'end_apply_check')
    else
      _start_time = self.start_time < Time.now ? (Time.now + 5.seconds) : self.start_time
      CampaignWorker.perform_at(_start_time, self.id, 'start')
    end
    CampaignWorker.perform_at(self.deadline ,self.id, 'end')
  end

  # 开始进行  此时需要更改invite状态
  def go_start
    Rails.logger.campaign_sidekiq.info "-----go_start:  ----start-----#{self.inspect}----------"
    ActiveRecord::Base.transaction do
      self.update_column(:max_action, (budget.to_f / per_action_budget.to_f).to_i)
      self.update_column(:status, 'executing')
      Message.new_campaign(self, get_specified_kol_ids, get_unmatched_kol_ids)
    end
  end

  def add_click(valid)
    Rails.logger.campaign_show_sidekiq.info "---------Campaign add_click: --valid:#{valid}----status:#{self.status}---avail_click:#{self.redis_avail_click.value}---#{self.redis_total_click.value}-"
    self.redis_avail_click.increment  if valid
    self.redis_total_click.increment
    if self.redis_avail_click.value.to_i >= self.max_action.to_i && self.status == 'executing' && (self.per_budget_type == "click" or self.is_cpa?)
      finish('fee_end')
    end
  end

  #finish_remark:  expired or fee_end
  def finish(finish_remark)
    self.reload
    Rails.logger.campaign_sidekiq.info "-----executed: #{finish_remark}----------"
    if Rails.application.config.china_instance  && self.status == 'executing'
      ActiveRecord::Base.transaction do
        update_info(finish_remark)
        end_invites
        settle_accounts_for_kol
        if !Rails.env.test?
          CampaignWorker.perform_at(Time.now + SettleWaitTimeForKol ,self.id, 'settle_accounts_for_kol')
          CampaignWorker.perform_at(Time.now + SettleWaitTimeForBrand ,self.id, 'settle_accounts_for_brand')
          CampaignWorker.perform_at(Time.now + RemindUploadWaitTime ,self.id, 'remind_upload')
        elsif Rails.env.test?
          CampaignWorker.new.perform(self.id, 'settle_accounts_for_kol')
          CampaignWorker.new.perform(self.id, 'settle_accounts_for_brand')
          CampaignWorker.new.perform(self.id, 'remind_upload')
        end
      end
    end
  end

  def update_info(finish_remark)
    self.update_attributes(:avail_click => self.redis_avail_click.value, :total_click => self.redis_total_click.value,
                            :status => 'executed', :finish_remark => finish_remark, :actual_deadline_time => Time.now)
  end

  # 更新invite 状态和点击数
  def end_invites
    campaign_invites.each do |invite|
      next if invite.status == 'finished' || invite.status == 'settled'  || invite.status == 'rejected'
      if invite.status == 'approved'
        invite.status = 'finished'
        invite.avail_click = invite.redis_avail_click.value
        invite.total_click = invite.redis_total_click.value
      elsif
        # receive but not apporve  we must delete
        invite.delete
      end
      invite.save!
    end
  end

  # 提醒上传截图
  def remind_upload
    Rails.logger.campaign_sidekiq.info "-----remind_upload:  ----start-----#{self.inspect}----------"
    Message.new_remind_upload(self)
  end

  # 结算 for kol
  def settle_accounts_for_kol
    Rails.logger.transaction.info "-------- settle_accounts_for_kol: cid:#{self.id}------status: #{self.status}"
    return if self.status != 'executed'
    ActiveRecord::Base.transaction do
      self.passed_invites.each do |invite|
        kol = invite.kol
        invite.update_column(:status, 'settled')
        if is_click_type? or is_cpa?
          kol.income(invite.avail_click * self.per_action_budget, 'campaign', self, self.user)
          Rails.logger.info "-------- settle_accounts_for_kol:  ---cid:#{self.id}--kol_id:#{kol.id}----credits:#{invite.avail_click * self.per_action_budget}-- after avail_amount:#{kol.avail_amount}"
        else
          kol.income(self.per_action_budget, 'campaign', self, self.user)
          Rails.logger.info "-------- settle_accounts_for_kol:  ---cid:#{self.id}--kol_id:#{kol.id}----credits:#{self.per_action_budget}-- after avail_amount:#{kol.avail_amount}"
        end
      end
    end
  end

  def is_click_type?
    self.per_budget_type == "click"
  end

  def is_post_type?
    self.per_budget_type == "post"
  end

  def is_recruit_type?
    self.per_budget_type == "recruit"
  end

  def recruit_status
    return 'pending' if self.status == 'unexecute'
    return 'rejected' if self.status == 'rejected'
    return 'coming' if self.status == 'agreed'
    return 'settling' if self.status == 'executed'
    return 'settled' if self.status == 'settled'

    if self.status == 'executing'
      if self.end_apply_check
        'running'
      elsif Time.now > self.recruit_end_time
        'choosing'
      else
        'inviting'
      end
    end

  end


  # 结算 for brand
  def settle_accounts_for_brand
    Rails.logger.transaction.info "-------- settle_accounts_for_brand: cid:#{self.id}------status: #{self.status}"
    return if self.status != 'executed'
    #首先先付款给期间审核的kol
    settle_accounts_for_kol
    #剩下的邀请  状态全设置为拒绝
    self.finished_invites.update_all(:status => 'rejected')
    ActiveRecord::Base.transaction do
      self.update_column(:status, 'settled')
      self.user.unfrozen(self.budget, 'campaign', self)
      Rails.logger.transaction.info "-------- settle_accounts: user  after unfrozen ---cid:#{self.id}--user_id:#{self.user.id}---#{self.user.avail_amount.to_f} ---#{self.user.frozen_amount.to_f}"
      if is_click_type?  || is_cpa?
        pay_total_click = self.settled_invites.sum(:avail_click)
        self.user.payout((pay_total_click * self.per_action_budget) , 'campaign', self )
        Rails.logger.transaction.info "-------- settle_accounts: user-------fee:#{pay_total_click * self.per_action_budget} --- after payout ---cid:#{self.id}-----#{self.user.avail_amount.to_f} ---#{self.user.frozen_amount.to_f}---\n"
      else
        settled_invite_size = self.settled_invites.size
        self.user.payout((self.per_action_budget * settled_invite_size) , 'campaign', self )
        Rails.logger.transaction.info "-------- settle_accounts: user-------fee:#{self.per_action_budget * settled_invite_size} --- after payout ---cid:#{self.id}-----#{self.user.avail_amount.to_f} ---#{self.user.frozen_amount.to_f}---\n"
      end
    end
  end

  def reset_campaign(origin_budget,new_budget, new_per_action_budget)
    Rails.logger.campaign.info "--------reset_campaign:  ---#{self.id}-----#{self.inspect} -- #{origin_budget}"
    self.user.unfrozen(origin_budget.to_f, 'campaign', self)
    Rails.logger.transaction.info "-------- reset_campaign:  after unfrozen ---cid:#{self.id}--user_id:#{self.user.id}---#{self.user.avail_amount.to_f} ---#{self.user.frozen_amount.to_f}"
    if self.user.avail_amount >= self.budget.to_f
      self.user.frozen(new_budget.to_f, 'campaign', self)
      Rails.logger.transaction.info "-------- reset_campaign:  after frozen ---cid:#{self.id}--user_id:#{self.user.id}---#{self.user.avail_amount.to_f} ---#{self.user.frozen_amount.to_f}"
    else
      Rails.logger.error("品牌商余额不足--reset_campaign - campaign_id: #{self.id}")
    end
  end

  def create_job
    if self.status_changed? && self.status == 'unexecute'
      Rails.logger.campaign.info "--------create_job:  ---#{self.id}-----#{self.inspect}"
      if self.user.avail_amount >= self.budget
        self.user.frozen(budget, 'campaign', self)
        Rails.logger.transaction.info "-------- create_job: after frozen  ---cid:#{self.id}--user_id:#{self.user.id}---#{self.user.inspect}"
      else
        Rails.logger.campaign.error "--------create_job:  品牌商余额不足--campaign_id: #{self.id} --------#{self.inspect}"
      end
    elsif (self.status_changed? && status == 'agreed')
      Rails.logger.campaign.info "--------agreed_job:  ---#{self.id}-----#{self.inspect}"
      if Rails.env.development? or Rails.env.test?
        CampaignWorker.new.perform(self.id, 'send_invites')
      else
        CampaignWorker.perform_async(self.id, 'send_invites')
      end
    elsif (self.status_changed? && status == 'rejected')
      Rails.logger.campaign.info "--------rejected_job:  ---#{self.id}-----#{self.inspect}"
      self.user.unfrozen(budget, 'campaign', self)
    end
  end

  #红包标签
  def is_red
    false
  end

  #最新标签
  def is_new
     self.status == 'executing' && self.start_time + 1.days > Time.now
  end

  #冲刺标签
  def is_sprint
    self.status == 'executing' && ((self.deadline - 4.hours < Time.now) || (self.remain_budget < 20) || (self.remain_budget < self.budget * 0.2))      rescue false
  end

  def get_campaign_invite(kol_id)
    invite = CampaignInvite.find_or_initialize_by(:campaign_id => self.id, :kol_id => kol_id)
    if invite.new_record? && self.status == 'executing'
      invite.status = 'running'
    elsif invite.new_record? && self.status == 'unexecuting'
      invite.status = 'pending'
    elsif invite.new_record? && (self.status == 'executed' ||  self.status == 'settled')
      invite.status = 'missed'
    end
    invite
  end

  def self.generate_campaign_reports kol_id
    invites = CampaignInvite.where(kol_id: kol_id, status: "finished")
    cookies = {}
    cookies_count = {}
    ips_count = {}

    CampaignShow.where(kol_id: kol_id).each do |show|
      cookies[show.campaign_id] ||= []
      cookies[show.campaign_id] << cookies

      cookies_count[show.visitor_cookie] ||= 0
      cookies_count[show.visitor_cookie] += 1
      ips_count[show.visitor_ip] ||= 0
      ips_count[show.visitor_ip] +=1
    end;nil
    cookies.count

    puts "该用户 已经完成 #{invites.count} 个campaigns"
    puts "总共有#{CampaignShow.where(kol_id: kol_id).count}个cookies"
    puts "-"*60
    puts "贡献点击数的 前10名 visitor_cookie"
    new_cookies_count = cookies_count.to_a.sort_by do |i|
     -i[1]
    end;nil
    new_cookies_count[0..10].each do |cookie_count|
      puts cookie_count
    end;nil
    puts "-"*60
    puts "贡献点击数的 前10名 ips"
    new_ips_count = ips_count.to_a.sort_by do |i|
     -i[1]
    end;nil
    new_ips_count[0..10].each do |ip_count|
      puts ip_count
    end;nil
    puts "-"*60
  end

end
