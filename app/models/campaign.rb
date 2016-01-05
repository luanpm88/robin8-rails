class Campaign < ActiveRecord::Base
  include Redis::Objects
  counter :redis_avail_click
  counter :redis_total_click

  belongs_to :user
  has_many :campaign_invites
  has_many :pending_invites, -> {where(:status => 'pending')}, :class_name => 'CampaignInvite'
  has_many :approved_invites, -> {where("status='approved' or status='finished'")}, :class_name => 'CampaignInvite'
  has_many :rejected_invites, -> {where(:status => 'rejected')}, :class_name => 'CampaignInvite'
  has_many :finished_invites, -> {where(:status => 'finished')}, :class_name => 'CampaignInvite'
  has_many :campaign_shows
  has_many :kols, through: :campaign_invites
  has_many :approved_kols, through: :approved_invites
  has_many :weibo_invites
  has_many :weibo, through: :weibo_invites
  has_many :articles
  has_many :kol_categories, :through => :kols

  has_many :campaign_categories
  has_many :iptc_categories, :through => :campaign_categories
  has_many :interested_campaigns
  belongs_to :release

  after_save :create_job

  def email
    user.try :email
  end

  def get_stats
    end_time = (status == 'executed' ? self.deadline : Time.now)
    shows = campaign_shows
    labels = []
    total_clicks = []
    avail_clicks = []
    (start_time.to_date..end_time.to_date).each do |date|
      labels << date.to_s
      total_clicks << shows.by_date(date.to_datetime).count
      avail_clicks << shows.valid.by_date(date.to_datetime).count
    end
    [labels, total_clicks, avail_clicks]
  end

  #统计信息
  def get_total_by_day
    self.campaign_shows.group("date_format(created_at, 'YYYY-MM-DD') ").select(" date_format(created_at, 'YYYY-MM-DD') as created, count(*) as count ")
  end

  def get_valid_by_day
    self.campaign_shows.valid.group("date_format(created_at, 'YYYY-MM-DD') ").select(" date_format(created_at, 'YYYY-MM-DD') as created, count(*) as count ")
  end


  def get_avail_click
    status == 'executed' ? self.avail_click : self.redis_avail_click.value      rescue 0
  end

  def get_total_click
    self.redis_total_click.value   rescue self.total_click
    # status == 'executed' ? self.total_click : self.redis_total_click.value      rescue 0
  end

  def get_fee_info
    "#{self.take_budget} / #{self.budget}"
  end

  def take_budget
    (get_avail_click * self.per_click_budget).round(2)       rescue 0
  end

  def remain_budget
    return 0 if status == 'executed'
    return (self.budget - self.take_budget).round(2)
  end

  def get_share_time
    return 0 if status == 'unexecute'
    status == 'executed' ? self.finished_invites.size : self.approved_invites.size
  end

  # 开始时候就发送邀请 但是状态为pending
  # c = Campaign.find xx
  # kol_ids = Kol.where("province like '%shanghai%'").collect{|t| t.id}
  # c.update_column(:status,'agreed')
  # c.send_invites(kol_ids)
  def send_invites(kol_ids = nil)
    Rails.logger.campaign_sidekiq.info "---send_invites: --campaign status: #{self.status}---#{self.deadline}----kol_ids:#{kol_ids}-"
    return if self.status != 'agreed'
    self.update_attribute(:status, 'rejected') && return if self.deadline < Time.now
    Rails.logger.campaign_sidekiq.info "---send_invites: --start create--"
    ActiveRecord::Base.transaction do
      kols = Kol.where(:id => kol_ids)  if kol_ids.present?
      (kols || Kol.all).each do |kol|
        next if CampaignInvite.exists?(:kol_id => kol.id, :campaign_id => self.id)
        invite = CampaignInvite.new
        invite.status = 'pending'
        invite.campaign_id = self.id
        invite.kol_id = kol.id
        uuid = Base64.encode64({:campaign_id => self.id, :kol_id=> kol.id}.to_json).gsub("\n","")
        invite.uuid = uuid
        invite.share_url = CampaignInvite.generate_share_url(uuid)
        invite.save!
      end
    end
    Rails.logger.campaign_sidekiq.info "----send_invites:  start push to sidekiq-------"
    # make sure those execute late (after invite create)
    _start_time = self.start_time < Time.now ? (Time.now + 15.seconds) : self.start_time
    Rails.logger.campaign_sidekiq.info "----send_invites:  _start_time:#{_start_time}-------"
    CampaignWorker.perform_at(_start_time, self.id, 'start')
    CampaignWorker.perform_at(self.deadline ,self.id, 'end')
  end

  def send_invite_to_kol kol, status
    invite = CampaignInvite.new
    invite.status = status
    invite.campaign_id = self.id
    invite.kol_id = kol.id
    uuid = Base64.encode64({:campaign_id => self.id, :kol_id=> kol.id}.to_json).gsub("\n","")
    invite.uuid = uuid
    invite.share_url = CampaignInvite.generate_share_url(uuid)
    invite.save!
  end

  # 开始进行  此时需要更改invite状态
  def go_start
    Rails.logger.campaign_sidekiq.info "-----go_start:  ----start-----#{self.inspect}----------"
    ActiveRecord::Base.transaction do
      self.update_column(:max_click, (budget.to_f / per_click_budget.to_f).to_i)
      self.update_column(:status, 'executing')
      self.pending_invites.update_all(:status => 'running')
    end
    Rails.logger.campaign_sidekiq.info "-----go_start:------end------- #{self.inspect}----------"
  end

  def add_click(valid)
    Rails.logger.campaign_show_sidekiq.info "---------Campaign add_click: --valid:#{valid}----status:#{self.status}---avail_click:#{self.redis_avail_click.value}---#{self.redis_total_click.value}-"
    self.redis_avail_click.increment  if valid
    self.redis_total_click.increment
    finish('fee_end') if self.redis_avail_click.value >= self.max_click && self.status == 'executing'
  end

  #finish_remark:  expired or fee_end
  def finish(finish_remark)
    Rails.logger.campaign_sidekiq.info "-----finish: #{finish_remark}----------"
    if Rails.application.config.china_instance  && self.status == 'executing'
      ActiveRecord::Base.transaction do
        update_info(finish_remark)
        end_invites
        settle_accounts
      end
    end
  end

  def update_info(finish_remark)
    self.avail_click = self.redis_avail_click.value
    self.total_click = self.redis_total_click.value
    self.status = 'executed'
    self.finish_remark = finish_remark
    self.save!
  end

  # 更新invite 状态和点击数
  def end_invites
    campaign_invites.each do |invite|
      if invite.status == 'approved'
        invite.status = 'finished'
        invite.avail_click = invite.redis_avail_click.value
        invite.total_click = invite.redis_total_click.value
      else
        invite.status = 'rejected'
      end
      invite.save!
    end
  end

  # 结算
  def settle_accounts
    self.user.unfrozen(budget, 'campaign', self)
    Rails.logger.transaction.info "-------- settle_accounts: user  after unfrozen ---cid:#{self.id}--user_id:#{self.user.id}---#{self.user.avail_amount.to_f} ---#{self.user.frozen_amount.to_f}"
    self.user.payout((avail_click * per_click_budget) , 'campaign', self )
    campaign = self
    self.finished_invites.each do |invite|
      invite.kol.income(invite.avail_click * campaign.per_click_budget, 'campaign', campaign, campaign.user)
      Rails.logger.transaction.info "-------- settle_accounts: kol  after income ---cid:#{campaign.id}--kol_id:#{invite.kol.id}---#{invite.kol.inspect}"
    end
  end


  def reset_campaign(origin_budget,new_budget, new_per_click_budget)
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
      CampaignWorker.perform_async(self.id, 'send_invites')
    elsif (self.status_changed? && status == 'rejected')
      Rails.logger.campaign.info "--------rejected_job:  ---#{self.id}-----#{self.inspect}"
      self.user.unfrozen(budget, 'campaign', self)
    end
  end


  def self.add_test_data
    if !Rails.env.production?
      u = User.find 81
      Campaign.create(:user => u, :budget => 1, :per_click_budget => 0.2, :start_time => Time.now + 10.seconds, :deadline => Time.now + 1.hours,
      :url => "http://www.baidu.com", :name => 'test')
    end
  end

end
