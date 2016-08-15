class Campaign < ActiveRecord::Base
  include Redis::Objects
  include Concerns::CampaignTest
  include Concerns::Testability
  include Campaigns::CampaignProcess
  counter :redis_avail_click
  counter :redis_total_click
  include Campaigns::CampaignTargetHelper
  include Campaigns::CampaignBaseHelper
  include Campaigns::AlipayHelper
  include Campaigns::ValidationHelper
  include Campaigns::StatsHelper

  validates_presence_of :name, :description, :per_budget_type, :start_time, :deadline
  validates_presence_of :per_action_budget, :budget, :if => Proc.new{ |campaign| campaign.per_budget_type != 'invite' }
  validates_presence_of :url, :if => Proc.new{ |campaign| ['click', 'post', 'cpa'].include? campaign.per_budget_type }
  validates_presence_of :recruit_start_time, :recruit_end_time, :if => Proc.new{ |campaign| campaign.per_budget_type == 'recruit' }
  #Status : unpay unexecute agreed rejected  executing executed
  #Per_budget_type click post cpa recruit invite
  # status ['unexecuted', 'agreed','rejected', 'executing','executed','settled', "revoked"]
  belongs_to :user
  has_many :campaign_invites
  # has_many :pending_invites, -> {where(:status => 'pending')}, :class_name => 'CampaignInvite'
  has_many :valid_invites, -> {where("status='approved' or status='finished' or status='settled'")}, :class_name => 'CampaignInvite'
  has_many :valid_applies, -> {where("status='platform_passed' or status='brand_passed'")}, :class_name => 'CampaignApply'
  has_many :brand_passed_applies, -> {where(status: 'brand_passed')}, :class_name => 'CampaignApply'
  has_many :rejected_invites, -> {where(:status => 'rejected')}, :class_name => 'CampaignInvite'
  has_many :finished_invites, -> {where(:status => 'finished')}, :class_name => 'CampaignInvite'
  has_many :finish_need_check_invites, -> {where(:status => 'finished', :img_status => 'pending').where("screenshot is not null")}, :class_name => 'CampaignInvite'
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
  has_many :campaign_materials

  scope :click_campaigns, -> {where(:per_budget_type => 'click')}
  scope :click_or_action_campaigns, -> {where("per_budget_type = 'click' or per_action_budget = 'cpa'")}
  scope :order_by_start, -> { order('start_time desc')}
  scope :order_by_status, -> { order(" case
                                         when campaigns.status = 'executing'  and campaigns.end_apply_check='1' then 2
                                         when campaigns.status = 'executing' then 3
                                         when campaigns.status ='executed' then 2
                                         else 1 end desc,
                                        start_time desc") }

  scope :completed, -> {where("status = 'executed' or status = 'settled'")}
  before_validation :format_url
  after_save :create_job
  before_create :genereate_campaign_number
  after_create :update_user_status
  after_save :deal_with_campaign_img_url

  OfflineProcess = ["点击立即报名，填写相关资料，完成报名","资质认证通过", "准时参与活动，并配合品牌完成相关活动", "根据品牌要求，完成相关推广任务", "上传任务截图", "任务完成，得到酬金"]
  BaseTaxRate = 0.3
  def email
    user.try :email
  end

  def upload_screenshot_deadline
    (self.actual_deadline_time ||self.deadline) +  SettleWaitTimeForBrand
  end

  def can_apply
    self.recruit_start_time < Time.now && Time.now < recruit_end_time
  end

  def get_stats api_from="brand"
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
    if total_clicks.size == 1 and api_from == "brand"
      labels.unshift "活动开始"
      total_clicks.unshift 0
      avail_clicks.unshift 0
    end
    [self.per_budget_type, labels, total_clicks, avail_clicks]
  end

  def get_stats_for_app
    if self.per_budget_type == "click" or self.per_budget_type == "cpa"
      get_stats('app')[1..-1]
    elsif self.per_budget_type == "post"
      get_stats('app')[1...-1]
    end
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

  def actual_budget(from_brand = true)
    from_brand ? budget :  (actual_per_action_budget * max_action).round(2)      rescue  budget
  end

  def get_per_action_budget(from_brand = true)
    from_brand ? per_action_budget : (actual_per_action_budget || cal_actual_per_action_budget)
  end

  def get_fee_info(from_brand = true)
    "#{self.take_budget(from_brand)} / #{self.actual_budget(from_brand)}"
  end

  def budget
    if self.attributes["budget"].to_i == self.attributes["budget"]
      self.attributes["budget"].to_i
    else
      self.attributes["budget"]
    end
  end

  def need_pay_amount
    if self.attributes["need_pay_amount"].to_i == self.attributes["need_pay_amount"]
      self.attributes["need_pay_amount"].to_i
    else
      self.attributes["need_pay_amount"]
    end
  end

  def pay_need_pay_amount
    self.update_attributes!(need_pay_amount: 0)
  end

  def set_pay_way(way)
    self.update_attributes!(pay_way: way)
  end

  def take_budget(from_brand = true)
    per_budget = self.get_per_action_budget(from_brand)
    if self.is_click_type? or self.is_cpa_type? or self.is_cpi_type?
      if self.status == 'settled'
        (self.settled_invites.sum(:avail_click) * per_budget).round(2)       rescue 0
      else
        (get_avail_click * per_budget).round(2)       rescue 0
      end
    else
      if self.status == 'settled'
        (self.settled_invites.count * per_budget).round(2) rescue 0
      else
        (self.valid_invites.count * per_budget).round(2) rescue 0
      end
    end
  end

  def remain_budget(from_brand = true)
    return (self.actual_budget(from_brand) - self.take_budget(from_brand)).round(2)
  end

  def post_count
    if self.per_budget_type == "click" or self.is_cpa_type?  or self.is_cpi_type?
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

  ['click', 'post', 'recruit', 'cpa', 'cpi', 'invite'].each do |value|
    define_method "is_#{value}_type?" do
      self.per_budget_type == value
    end
  end

  def recruit_status
    return 'unpay' if self.status == 'unpay'
    return 'pending' if self.status == 'unexecute'
    return 'rejected' if self.status == 'rejected'
    return 'coming' if self.status == 'agreed'
    return 'settling' if self.status == 'executed'
    return 'settled' if self.status == 'settled'

    if self.status == 'executing'
      if self.end_apply_check
        'running'
      elsif Time.now >= self.recruit_end_time
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
    raise 'status 不能为空' if self.status.blank?
    # if self.need_pay_amount == 0 and self.status.to_s == 'unpay'
    #   self.update_attributes :status => 'unexecute'
    # end
    # if self.status_changed? && self.status.to_s == 'unexecute'
    #   if not self.campaign_from ==  "app"
    #     if self.user.avail_amount >= self.need_pay_amount
    #       self.user.payout(need_pay_amount, 'campaign', self)
    #       Rails.logger.transaction.info "-------- create_job: after payout  ---cid:#{self.id}--user_id:#{self.user.id}---#{self.user.inspect}"
    #     else
    #       Rails.logger.campaign.error "--------create_job:  品牌商余额不足--campaign_id: #{self.id} --------#{self.inspect}"
    #     end
    #   end
    if (self.status_changed? && status.to_s == 'agreed')
      self.update_column(:check_time, Time.now)
      if Rails.env.development? or Rails.env.test?
        CampaignWorker.new.perform(self.id, 'send_invites')
      else
        CampaignWorker.perform_async(self.id, 'send_invites')
      end
    elsif (self.status_changed? && status.to_s == 'rejected')
      self.update_column(:check_time, Time.now)
      Rails.logger.campaign.info "--------rejected_job:  ---#{self.id}-----#{self.inspect}"
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

  def format_url
    # http://www.cnblogs.com/txw1958/p/weixin71-oauth20.html
    # 直接在微信打开链接，可以不填此参数。做页面302重定向时候，必须带此参数

    url_changed = self.url_changed?
    begin
      unless self.url.downcase.start_with?("http:") || self.url.downcase.start_with?("https:")
        self.url = "http://" + self.url
      end

      if URI(self.url).host == "mp.weixin.qq.com"
        self.url = self.url.gsub("#rd", "")
        if not self.url.include?("#wechat_redirect")
          self.url = self.url + "#wechat_redirect"
        end
      end
    rescue Exception => e
      # 出错了 就不更新url
    end
    if url_changed
      if not self.url.downcase.match(Regexp.new("((https?|ftp|file):((//)|(\\\\))+[\w\d:\#@%/;$()~_?\+-=\\\\.&]*)")) or self.url.downcase.include?("..") or (not self.url.include?("."))
        self.errors[:url] = "活动链接格式不正确"
        return false
      end
    end
  end

  def genereate_campaign_number
    self.trade_number = Time.now.strftime("%Y%m%d%H%M%S") + "#{rand(10000..99999)}"
  end

  def update_user_status
    unless self.user.is_active
      self.user.update(:is_active => true)
    end
  end

  def deal_with_campaign_img_url
    if self.img_url.present? and self.img_url_changed?
      file_name = URI(self.img_url).path.downcase[1..-1]
      if file_name.end_with?("png") || file_name.end_with?("jpg") || file_name.end_with?("jpeg")
        CampaignImgWorker.perform_async(self.id, self.img_url)
      end
    end
  end
end
