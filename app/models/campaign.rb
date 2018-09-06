# actual_per_action_budget: amount paid to KOL (currently 60% of per_action_budget)
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
  include Campaigns::CampaignAnalysis
  include Campaigns::CampaignInviteAnalysis

  list :push_device_tokens

  STATUS = {
    unpay:      '未支付',
    pending:    '已支付，待审核',
    agreed:     '审核通过',
    executing:  '执行中',
    executed:   '已完成，未结算',
    settled:    '已结算',
    finished:   '已结束',
    unexecute:  '未执行',
    rejected:   '已拒绝'
  }


  AuthTypes = {'no' => '无需授权', 'base' => '获取基本信息(openid)', 'self_info' => "获取详细信息(只获取自己)", 'friends_info' => "获取详细信息(获取好友)"}
  ExampleScreenshots = Hash.new
  ExampleScreenshots.default={
    weibo:  "http://7xozqe.com1.z0.glb.clouddn.com/weibo_example.jpg",
    qq:     "http://7xozqe.com1.z0.glb.clouddn.com/qq_example.jpg",
    wechat: 'http://7xozqe.com1.z0.glb.clouddn.com/wechat_example.jpg',
  }
  ExampleScreenshots[16344] = {
    weibo:  "http://7xozqe.com1.z0.glb.clouddn.com/Bayer.png",
    qq:     "http://7xozqe.com1.z0.glb.clouddn.com/Bayer.png",
    wechat: 'http://7xozqe.com1.z0.glb.clouddn.com/Bayer.png',
  }

  validates_presence_of :name, :description, :per_budget_type, :start_time, :deadline
  validates_presence_of :per_action_budget, :budget, :if => Proc.new{ |campaign| campaign.per_budget_type != 'invite' }
  validates_presence_of :url, :if => Proc.new{ |campaign| ['click', 'post', 'cpa', 'simple_cpi','cpt'].include? campaign.per_budget_type }
  validates_presence_of :recruit_start_time, :recruit_end_time, :if => Proc.new{ |campaign| campaign.per_budget_type == 'recruit' }
  validates :sub_type, :inclusion => { :in => ["wechat", "qq", "weibo" , "wechat,weibo"] }, :allow_nil => true
  # validates :wechat_auth_type, :inclusion => { :in => AuthTypes.keys }
  #Status : unpay unexecute agreed rejected  executing executed
  #Per_budget_type click post cpa simple_cpi cpi recruit invite
  # status ['unexecuted', 'agreed','rejected', 'executing','executed','settled', "revoked"]
  belongs_to :user
  has_many :campaign_invites
  # has_many :pending_invites, -> {where(:status => 'pending')}, :class_name => 'CampaignInvite'
  has_many :valid_invites, -> {where("status='approved' or status='finished' or status='settled'")}, :class_name => 'CampaignInvite'
  has_many :valid_applies, -> {where("status='platform_passed' or status='brand_passed' or status='brand_rejected'")}, :class_name => 'CampaignApply'
  has_many :brand_passed_applies, -> {where(status: 'brand_passed')}, :class_name => 'CampaignApply'
  has_many :rejected_invites, -> {where(:status => 'rejected')}, :class_name => 'CampaignInvite'
  has_many :finished_invites, -> {where(:status => 'finished')}, :class_name => 'CampaignInvite'
  has_many :wait_pass_invites, -> {where(screenshot: 'wait_pass')}, class_name: 'CampaignInvite'
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
  has_many :kol_tags, :through => :kols
  has_many :campaign_action_urls, autosave: true

  has_many :campaign_categories
  has_many :iptc_categories, :through => :campaign_categories
  has_many :interested_campaigns
  belongs_to :release
  has_many :campaign_applies
  has_many :campaign_materials
  has_many :campaign_push_records, class_name: "CampaignPushRecord"

  has_many :e_wallet_transtions, as: :resource, class: EWallet::Transtion

  scope :click_campaigns, -> {where(:per_budget_type => 'click')}
  scope :click_or_action_campaigns, -> {where("per_budget_type = 'click' or per_action_budget = 'cpa'")}
  scope :recent_7, ->{ where("deadline > '#{7.days.ago}'")}
  scope :order_by_start, -> { order('start_time desc')}
  scope :countdown, -> { where(status: "countdown")}
  has_one :effect_evaluation, -> {where(item: 'effect')}, class: CampaignEvaluation
  has_one :experience_evaluation, -> {where(item: 'experience')}, class: CampaignEvaluation
  has_one :review_evaluation, -> {where(item: 'review')}, class: CampaignEvaluation
  has_many :credits, as: :resource
  scope :is_present_puts, ->{ where(is_present_put: true)}


  # 报名中的招募活动和特邀活动最优先,其次是参加中的招募活动,再是进行中的活动(招募报名失败的除外)
  scope :order_by_status, ->(ids = '""') { order(" case
                                         when campaigns.per_budget_type = 'invite' and campaigns.status = 'executing'  then 6
                                         when campaigns.per_budget_type = 'recruit' and campaigns.status = 'executing' and campaigns.end_apply_check != '1' then 6
                                         when campaigns.per_budget_type = 'recruit' and (campaigns.status = 'executed' or (campaigns.status = 'executing' and campaigns.end_apply_check = '1') ) and campaigns.id in (#{ids}) then 5
                                         when campaigns.per_budget_type != 'recruit' and campaigns.status = 'executing'  then 4
                                         when campaigns.per_budget_type = 'recruit' and campaigns.status = 'executing' and campaigns.end_apply_check = '1' then 3
                                         when campaigns.status = 'countdown' then 2
                                         when campaigns.status = 'executed' then 1
                                         else 0 end desc,
                                        start_time desc") }

  scope :completed, -> {where("status = 'executed' or status = 'settled'")}
  scope :agreed, -> {where(status: ["agreed", "executing", "executed", "settled"])}

  scope :valid_invites, -> { joins("LEFT JOIN (SELECT `campaign_invites`.`campaign_id` AS campaign_id, COUNT(*) AS valid_invite_count FROM `campaign_invites` WHERE `campaign_invites`.`status` = 'approved' OR `campaign_invites`.`status` = 'finished' OR `campaign_invites`.`status` = 'settled' GROUP BY `campaign_invites`.`campaign_id`) AS `cte_tables` ON `campaigns`.`id` = `cte_tables`.`campaign_id`") }
  scope :total_invites, -> { joins("LEFT JOIN (SELECT `campaign_invites`.`campaign_id` AS campaign_id, COUNT(*) AS total_invite_count FROM `campaign_invites` GROUP BY `campaign_invites`.`campaign_id`) AS `cte_tables` ON `campaigns`.`id` = `cte_tables`.`campaign_id`") }
  scope :sort_by_valid_invite_count, ->(dir) { valid_invites.order("valid_invite_count #{dir}") }
  scope :sort_by_total_invite_count, ->(dir) { total_invites.order("total_invite_count #{dir}") }

  before_validation :format_url
  after_save :create_job
  before_create :generate_campaign_number, :deal_wechat_auth_type
  before_create :change_present_put, if: ->{$redis.get('put_switch') == '1'}
  after_create :update_user_status
  after_save :deal_with_campaign_img_url
  after_create :valid_owner_credit # 验证当前用户的积分是否有效
  after_save :generate_campaign_e_wattle_transactions, if: ->{$redis.get('put_switch') == '1' && status_changed? }

  OfflineProcess = ["点击立即报名，填写相关资料，完成报名","资质认证通过", "准时参与活动，并配合品牌完成相关活动", "根据品牌要求，完成相关推广任务", "上传任务截图", "任务完成，得到酬金"]
  BaseTaxRate = 0.3
  ReceiveCampaignInterval = Rails.env.production? ? 2.hours : 1.second

  def email
    user.try :email
  end

  def upload_screenshot_deadline
    (self.actual_deadline_time ||self.deadline) +  SettleWaitTimeForBrand
  end

  def valid_owner_credit
    user.invalid_credit
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
    elsif self.per_budget_type.in?(["post", "simple_cpi", "cpt"])
      get_stats('app')[1...-1]
    end
  end

  def need_finish
    self.per_budget_type.in?(["post", "simple_cpi", "cpt"]) && self.valid_invites.size >= self.max_action && self.status == 'executing'
  end

  #统计信息
  def get_total_by_day
    self.campaign_shows.group("date_format(created_at, 'YYYY-MM-DD') ").select(" date_format(created_at, 'YYYY-MM-DD') as created, count(*) as count ")
  end

  def get_valid_by_day
    self.campaign_shows.valid.group("date_format(created_at, 'YYYY-MM-DD') ").select(" date_format(created_at, 'YYYY-MM-DD') as created, count(*) as count ")
  end

  def get_avail_click
    if status == 'settled'
      settled_invites.sum(:avail_click)
    else
      self.redis_avail_click.value rescue self.avail_click
    end
  end

  def get_total_click
    self.redis_total_click.value rescue self.total_click
  end

  def actual_budget(from_brand = true)
    if self.is_invite_type?
      self.campaign_invites.sum(:price)
    else
      from_brand ? budget :  (actual_per_action_budget * max_action).round(2)      rescue  budget
    end
  end

  #返回的entity 中会根据当前用户的价格覆盖
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
    elsif self.is_post_type? || self.is_simple_cpi_type? || self.is_recruit_type? || self.is_cpt_type?
      if self.status == 'settled'
        (self.settled_invites.count * per_budget).round(2) rescue 0
      else
        (self.valid_invites.count * per_budget).round(2) rescue 0
      end
    elsif self.is_invite_type?
      if from_brand
        self.campaign_invites.where(:status => ['approved', 'finished', 'settled']).sum(:sale_price)
      else
        self.campaign_invites.where(:status => ['approved', 'finished', 'settled']).sum(:price)
      end
    end
  end

  #根据点击量  #only cpc cpp
  def budget_stats_by_day
    return [] unless ['executing', 'executed', 'settled'].include? self.status
    campaign = self
    if self.is_click_type?
      avail_stats = CampaignShow.where(campaign_id: self.id).group("date(created_at)").
        select("date(created_at) as date, sum(status) as avail")
    elsif self.is_post_type? || self.is_simple_cpi_type?  || self.is_cpt_type?
      avail_stats = CampaignInvite.where(campaign_id: self.id, status: ['approved', 'finished', 'settled'])
                      .group("date(approved_at)").select("date(approved_at) as date, count(*) as avail")
    end
    avail_stats.collect{|t| {time: t.date, avail: t.avail, take_budget: t.avail * campaign.per_action_budget}}   rescue []
  end

  def remain_budget(from_brand = true)
    return (self.actual_budget(from_brand) - self.take_budget(from_brand)).round(2)  rescue nil
  end

  def post_count
    if self.is_click_type? or self.is_cpa_type?  or self.is_cpi_type?
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

  # 活动类型的判断方法的封装
  ['click', 'post', 'recruit', 'cpa', 'simple_cpi' ,'cpi', 'invite', 'cpt'].each do |value|
    define_method "is_#{value}_type?" do
      self.per_budget_type == value
    end
  end

  #活动状态判断方法的封装
  ['unpay','pending','agreed','executing','executed','settled','finished','unexecute','rejected'].each do |value|
    define_method "is_#{value}_status?" do
      self.status == value
    end
  end


  def recruit_status
    case self.status
    when 'unpay'
      return 'unpay'
    when 'unexecute'
      return 'pending'
    when 'rejected'
      return 'rejected'
    when 'agreed'
      return 'coming'
    when 'executed'
      return 'settling'
    when 'settled'
      return 'settled'
    when 'executing'
      if self.end_apply_check
        return 'running'
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

  AdminPhones = ['18817774892', '15298670933', '13764432765', '13262752287', '15154196577' , '18551526463' ,'18321878526','13915128156','15152331980','15298675346','18817774892','15606172163']
  def create_job
    raise 'status 不能为空' if self.status.blank?
    if (self.status_changed? && status.to_s == 'unexecute') && Rails.env.production?
      #send sms to admin to check campaign
      SmsMessage.send_by_resource_to(AdminPhones, "有新的活动需要审核 (#{self.name})", self, {:mode => 'campaign_check' })
    elsif (self.status_changed? && status.to_s == 'agreed')
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

  def example_screenshot_required?
    %w(simple_cpi recruit cpt).include? self.per_budget_type
  end

  def get_campaign_invite(kol_id)
    invite = CampaignInvite.find_or_initialize_by(:campaign_id => self.id, :kol_id => kol_id)
    if invite.new_record? && self.status == 'executing'
      invite.status = 'running'
    elsif invite.new_record? && self.status == 'unexecuting'
      invite.status = 'pending'
    elsif invite.new_record? && (self.status == 'executed' ||  self.status == 'settled')
      invite.status = 'missed'
    elsif self.status == 'countdown'
      invite.status = 'countdown'
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

  def self.ransortable_attributes(auth_object = nil)
    ransackable_attributes(auth_object) + %w( sort_by_valid_invite_count sort_by_total_invite_count )
  end

  def format_url
    # http://www.cnblogs.com/txw1958/p/weixin71-oauth20.html
    # 直接在微信打开链接，可以不填此参数。做页面302重定向时候，必须带此参数

    url_changed = self.url_changed?
    begin
      unless self.url.downcase.start_with?("http:") || self.url.downcase.start_with?("https:")
        self.url = "http://" + self.url
      end

      if URI(URI.encode(self.url)).host == "mp.weixin.qq.com"
        self.url = self.url.gsub("#rd", "")
        if not self.url.include?("#wechat_redirect")
          self.url = self.url + "#wechat_redirect"
        end
      end
    rescue Exception => e
      # 出错了 就不更新url
    end
    if url_changed
      if self.per_budget_type == 'recruit' && self.sub_type.blank?
        return
      end
      if not self.url.downcase.match(Regexp.new("((https?|ftp|file):((//)|(\\\\))+[\w\d:\#@%/;$()~_?\+-=\\\\.&]*)")) or self.url.downcase.include?("..") or (not self.url.include?("."))
        self.errors[:url] = "活动链接格式不正确"
        return false
      end
    end
  end

  def generate_campaign_number
    self.trade_number = Time.now.strftime("%Y%m%d%H%M%S") + "#{rand(10000..99999)}"
  end

  def update_user_status
    unless self.user.is_active
      self.user.update(:is_active => true)
    end
  end

  def deal_with_campaign_img_url
    if self.img_url.present? and self.img_url_changed?
      file_name = URI(URI.encode(self.img_url)).path.downcase[1..-1]
      if file_name.end_with?("png") || file_name.end_with?("jpg") || file_name.end_with?("jpeg")
        CampaignImgWorker.perform_async(self.id, self.img_url)
      end
    end
  end

  def get_example_screenshot(multi = false)
    #multi 区别是否返回多图,适配老版本
    if self.example_screenshot.present?
      example_screenshot = self.example_screenshot.split(",")   rescue []
      return example_screenshot[0]   unless multi
      return example_screenshot
    else
      return ExampleScreenshots[user_id][sub_type.to_sym] unless multi
      return ExampleScreenshots[user_id][sub_type.to_sym].split
    end
  end

  def deal_wechat_auth_type
    self.sub_type ||= 'wechat'
    if self.sub_type == 'wechat' && self.per_budget_type != 'simple_cpi'
      self.wechat_auth_type = 'base'
    else
      self.wechat_auth_type = 'no'
    end
  end

  def review_content
    self.review_evaluation.content rescue nil
  end

  def effect_score
    self.effect_evaluation.score rescue nil #'5'   #默认显示5分
  end

  def create_share_url(kol)
    kol.add_campaign_id(self.id)
    kol.approve_campaign(self.id)
    campaign_invite = self.get_campaign_invite(kol.id) rescue nil
    if campaign_invite
      campaign_invite_uuid = campaign_invite.uuid
      Rails.logger.partner_campaign.info "--campaign_details: campaign_invite_uuid #{campaign_invite_uuid}"
      share_url = campaign_invite.visit_url if campaign_invite_uuid
      Rails.logger.partner_campaign.info "--campaign_details: share_url #{share_url}"
    end
    Rails.logger.partner_campaign.info "--campaign_details: share_url #{share_url}"
    share_url ||= "#{Rails.application.secrets.domain}/campaign_visit?campaign_id=#{self.id}" rescue ''
    return [campaign_invite , share_url]
  end

  def get_push_record_id
    record = self.campaign_push_records.where(filter_reason: 'match').last
    if record && record.kol_ids.present?
      record.kol_ids.split(",")
    else
      nil
    end
  end

  def campaign_invites_by_tag(tag)
    campaign_invites.joins(kol: :admintags).where("admintags.tag =?", tag.tag)
  end

  def campaign_shows_by_tag(tag)
    campaign_shows.joins(kol: :admintags).where("admintags.tag =?", tag.tag)
  end

  # 机器人刷点击 start
  def avg_avail_click
    valid_invites.empty? ? 0 : redis_avail_click.value.to_i / valid_invites.count
  end

  def need_add_avail_click
    (remain_budget / per_action_budget).to_i
  end

  def need_add_kols_count
    need_add_avail_click / (avg_avail_click == 0 ?  (2...6).to_a.sample : avg_avail_click)
  end
  # 机器人刷点击 end

  def reset_unpay_info
    self.update_attributes(used_credit: false, credit_amount: 0, need_pay_amount: budget) if used_credit && status == 'unpay'
  end

  # 爆光数
  def exposures_count
    campaign_invites.count * 500
  end

  def add_robots_under_settled
    return false if status != 'settled'

    if is_click_type?
      avail_click  = (remain_budget/per_action_budget).to_i
      kols_count   = need_add_avail_click
    else
      kols_count  = (remain_budget/per_action_budget).to_i
      avail_click = kols_count
    end

    click_ary = MathExtend.rand_array(avail_click, kols_count)

    Kol.where(channel: 'robot').sample(kols_count).each_with_index do |k, index|
      ci = CampaignInvite.find_or_initialize_by(campaign_id: id, kol_id: k.id)

      if ci.new_record?
        uuid      = Base64.encode64({campaign_id: id, kol_id: k.id}.to_json).gsub("\n","")
        short_url = ShortUrl.convert("#{Rails.application.secrets.domain}/campaign_show?uuid=#{uuid}")

        ci.img_status   = 'passed'
        ci.approved_at  = Time.now
        ci.status       = 'settled'
        ci.uuid         = uuid
        ci.share_url    = short_url
        ci.avail_click  = click_ary[index]
        ci.total_click  = click_ary[index] + rand(5)
        ci.save
      end

      ci.redis_avail_click.incr ci.avail_click
      ci.redis_total_click.incr ci.total_click

      self.redis_avail_click.incr ci.redis_avail_click.value
      self.redis_total_click.incr ci.redis_total_click.value
    end

    self.update_columns(avail_click: self.redis_avail_click.value, total_click: self.redis_total_click.value)
  end

  def generate_campaign_e_wattle_transactions
    amount = $redis.get('put_count').to_i
    if self.is_settled_status?
      self.kols.joins(:e_wallet_account).each do |kol|
        kol.e_wallet_transtions.find_or_create_by(resource: self, amount: amount)
      end
    end
  end

  def change_present_put
    self.is_present_put = true
  end
  #在点击审核通过前，再次判断该活动的状态，防止这期间品牌主取消此活动。
  # def can_check?
  #   authorize! :manage, Campaign
  #   self.reload
  #   if self.status == "unexecute"
  #     return true
  #   else
  #     return false
  #   end
  # end

end
