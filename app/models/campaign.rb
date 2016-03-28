class Campaign < ActiveRecord::Base
  include Redis::Objects
  counter :redis_avail_click
  counter :redis_total_click

  validates_presence_of :name, :description, :url, :budget, :per_budget_type, :per_action_budget, :start_time, :deadline

  #Status : unexecute agreed rejected  executing executed
  #Per_budget_type click post cpa
  belongs_to :user
  has_many :campaign_targets
  has_many :campaign_invites
  # has_many :pending_invites, -> {where(:status => 'pending')}, :class_name => 'CampaignInvite'
  has_many :valid_invites, -> {where("status='approved' or status='finished' or status='settled'")}, :class_name => 'CampaignInvite'
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

  scope :click_campaigns, -> {where(:per_budget_type => 'click')}
  scope :order_by_start, -> { order('start_time desc')}
  scope :order_by_status, -> { order("case campaigns.status  when 'executing' then 3 when 'executed' then 2 else 1 end desc,
                                      start_time desc") }

  scope :completed, -> {where("status = 'executed' or status = 'settled'")}
  after_save :create_job

  SettleWaitTimeForKol = Rails.env.production?  ? 1.days  : 1.hours
  SettleWaitTimeForBrand = Rails.env.production?  ? 4.days  : 4.hours
  def email
    user.try :email
  end

  def upload_screenshot_deadline
    (self.actual_deadline_time ||self.deadline) +  SettleWaitTimeForKol
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
    # status == 'executed' ? self.avail_click : self.redis_avail_click.value      rescue 0
  end

  def get_total_click
    self.redis_total_click.value   rescue self.total_click
    # status == 'executed' ? self.total_click : self.redis_total_click.value      rescue 0
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
    # return 0 if (status == 'executed' || status == 'settled')
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
  # c = Campaign.find xx
  # kol_ids = Kol.where("province like '%shanghai%'").collect{|t| t.id}
  # c.update_column(:status,'agreed')
  # c.send_invites(kol_ids)
  def send_invites(kol_ids = nil)
    _start = Time.now
    Rails.logger.campaign_sidekiq.info "---send_invites: cid:#{self.id}--campaign status: #{self.status}---#{self.deadline}----kol_ids:#{kol_ids}-"
    return if self.status != 'agreed'
    self.update_attribute(:status, 'rejected') && return if self.deadline < Time.now
    Rails.logger.campaign_sidekiq.info "---send_invites: -----cid:#{self.id}--start create--"
    campaign_id = self.id
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
    # 删除黑名单campaign
    block_kols = Kol.where("forbid_campaign_time > '#{Time.now}'")
    block_kols.each do |kol|
      kol.delete_campaign_id campaign_id
    end
    Rails.logger.campaign_sidekiq.info "---send_invites: ---cid:#{self.id}--campaign block_kol_ids: ---#{block_kols.collect{|t| t.id}}-"
    Rails.logger.campaign_sidekiq.info "----send_invites: ---cid:#{self.id}-- start push to sidekiq-------"
    # make sure those execute late (after invite create)
    _start_time = self.start_time < Time.now ? (Time.now + 5.seconds) : self.start_time
    Rails.logger.campaign_sidekiq.info "----send_invites: ---cid:#{self.id} _start_time:#{_start_time}-------"
    CampaignWorker.perform_at(_start_time, self.id, 'start')
    CampaignWorker.perform_at(self.deadline ,self.id, 'end')
    Rails.logger.campaign_sidekiq.info "\n\n-------duration:#{Time.now - _start}---\n\n"
  end


  # 开始进行  此时需要更改invite状态
  def go_start
    Rails.logger.campaign_sidekiq.info "-----go_start:  ----start-----#{self.inspect}----------"
    ActiveRecord::Base.transaction do
      self.update_column(:max_action, (budget.to_f / per_action_budget.to_f).to_i)
      self.update_column(:status, 'executing')
      Message.new_campaign(self)
      # self.pending_invites.update_all(:status => 'running')
    end
    Rails.logger.campaign_sidekiq.info "-----go_start:------end------- #{self.inspect}----------\n"
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
        if Rails.env.production?
          CampaignWorker.perform_at(Time.now + SettleWaitTimeForKol ,self.id, 'settle_accounts_for_kol')
          CampaignWorker.perform_at(Time.now + SettleWaitTimeForBrand ,self.id, 'settle_accounts_for_brand')
        elsif Rails.env.development? or Rails.env.staging?
          CampaignWorker.perform_at(Time.now + SettleWaitTimeForKol ,self.id, 'settle_accounts_for_kol')
          CampaignWorker.perform_at(Time.now + SettleWaitTimeForBrand ,self.id, 'settle_accounts_for_brand')
        elsif Rails.env.test?
          CampaignWorker.new.perform(self.id, 'settle_accounts_for_kol')
          CampaignWorker.new.perform(self.id, 'settle_accounts_for_brand')
        end
      end
    end
  end

  def update_info(finish_remark)
    self.avail_click = self.redis_avail_click.value
    self.total_click = self.redis_total_click.value
    self.status = 'executed'
    self.finish_remark = finish_remark
    Rails.logger.campaign.info "======update_info----#{Time.now}"
    self.actual_deadline_time = Time.now
    self.save!
  end

  # 更新invite 状态和点击数
  def end_invites
    campaign_invites.each do |invite|
      next if invite.status == 'finished' || invite.status == 'settled'
      if invite.status == 'approved'
        invite.status = 'finished'
        invite.avail_click = invite.redis_avail_click.value
        invite.total_click = invite.redis_total_click.value
      elsif
        # receive but not apporve  we must delete
        invite.delete
      else
        invite.status = 'rejected'
      end
      invite.save!
    end
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

  # 结算 for brand
  def settle_accounts_for_brand
    Rails.logger.transaction.info "-------- settle_accounts_for_brand: cid:#{self.id}------status: #{self.status}"
    return if self.status != 'executed'
    #首先先付款给期间审核的kol
    settle_accounts_for_kol
    #没审核通过的设置为拒绝
    self.finish_need_check_invites.update_all(:status => 'rejected')
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
    self.status == 'executeing' && ((self.deadline - 4.hours < Time.now) || (self.remain_budget < 20) || (self.remain_budget < self.budget * 0.2))      rescue false
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
