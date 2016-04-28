class Campaign < ActiveRecord::Base
  include Redis::Objects
  include Concerns::CampaignTest
  include Concerns::Campaigns::CampaignProcess
  counter :redis_avail_click
  counter :redis_total_click
  include Campaigns::CampaignTargetHelper
  include Campaigns::CampaignBaseHelper

  validates_presence_of :name, :description, :url, :budget, :per_budget_type, :per_action_budget, :start_time, :deadline, :if => Proc.new{ |campaign| campaign.per_budget_type != 'recruit' }
  validates_presence_of :name, :description, :task_description, :budget, :per_budget_type, :per_action_budget, :recruit_start_time, :recruit_end_time, :start_time, :deadline, :if => Proc.new{ |campaign| campaign.per_budget_type == 'recruit' }

  #Status : unexecute agreed rejected  executing executed
  #Per_budget_type click post cpa
  # status ['unexecuted', 'agreed','rejected', 'executing','executed','settled']
  belongs_to :user
  has_many :campaign_invites
  # has_many :pending_invites, -> {where(:status => 'pending')}, :class_name => 'CampaignInvite'
  has_many :valid_invites, -> {where("status='approved' or status='finished' or status='settled'")}, :class_name => 'CampaignInvite'
  has_many :valid_applies, -> {where("status='platform_passed' or status='brand_passed'")}, :class_name => 'CampaignApply'
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
    if self.is_click_type? or self.is_cpa_type?
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
    if self.per_budget_type == "click" or self.is_cpa_type?
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


  def add_click(valid)
    Rails.logger.campaign_show_sidekiq.info "---------Campaign add_click: --valid:#{valid}----status:#{self.status}---avail_click:#{self.redis_avail_click.value}---#{self.redis_total_click.value}-"
    self.redis_avail_click.increment  if valid
    self.redis_total_click.increment
    if self.redis_avail_click.value.to_i >= self.max_action.to_i && self.status == 'executing' && (self.per_budget_type == "click" or self.is_cpa_type?)
      finish('fee_end')
    end
  end

  # 提醒上传截图
  def remind_upload
    Rails.logger.campaign_sidekiq.info "-----remind_upload:  ----start-----#{self.inspect}----------"
    Message.new_remind_upload(self)
  end

  ['click', 'post', 'recruit', 'cpa'].each do |value|
    define_method "is_#{value}_type?" do
      self.per_budget_type == value
    end
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

  def recruit_person_count
    self.budget / self.per_action_budget
  end

  def create_job
    if self.status_changed? && self.status == 'unexecute'
      if self.user.avail_amount >= self.budget
        self.user.frozen(budget, 'campaign', self)
        Rails.logger.transaction.info "-------- create_job: after frozen  ---cid:#{self.id}--user_id:#{self.user.id}---#{self.user.inspect}"
      else
        Rails.logger.campaign.error "--------create_job:  品牌商余额不足--campaign_id: #{self.id} --------#{self.inspect}"
      end
    elsif (self.status_changed? && status == 'agreed')
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
