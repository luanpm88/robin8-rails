class Campaign < ActiveRecord::Base
  include Redis::Objects
  counter :redis_avail_click
  counter :redis_total_click

  #Status : unexecute agreed rejected  executing executed
  #Per_budget_type click post
  belongs_to :user
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

  SettleWaitTimeForKol = Rails.env.production?  ? 1.days  : 5.minutes
  SettleWaitTimeForBrand = Rails.env.production?  ? 4.days  : 10.minutes
  def email
    user.try :email
  end

  def upload_screenshot_deadline
    (self.actual_deadline_time ||self.deadline) +  SettleWaitTimeForKol
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
    if self.is_click_type?
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
    if self.per_budget_type == "click"
      return -1
    end
    return valid_invites.count
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
    if self.redis_avail_click.value >= self.max_action && self.status == 'executing' && self.per_budget_type == "click"
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
        if is_click_type?
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

  # 结算 for brand
  def settle_accounts_for_brand
    Rails.logger.transaction.info "-------- settle_accounts_for_brand: cid:#{self.id}------status: #{self.status}"
    return if self.status != 'executed'
    #首先先付款给期间审核的kol
    # settle_accounts_for_kol
    #没审核通过的设置为拒绝
    self.finish_need_check_invites.update_all(:img_status => 'rejected')
    ActiveRecord::Base.transaction do
      self.update_column(:status, 'settled')
      self.user.unfrozen(self.budget, 'campaign', self)
      Rails.logger.transaction.info "-------- settle_accounts: user  after unfrozen ---cid:#{self.id}--user_id:#{self.user.id}---#{self.user.avail_amount.to_f} ---#{self.user.frozen_amount.to_f}"
      if is_click_type?
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
      if Rails.env.development?
        CampaignWorker.new.perform(self.id, 'send_invites')
      else
        CampaignWorker.perform_async(self.id, 'send_invites')
      end
    elsif (self.status_changed? && status == 'rejected')
      Rails.logger.campaign.info "--------rejected_job:  ---#{self.id}-----#{self.inspect}"
      self.user.unfrozen(budget, 'campaign', self)
    end
  end

  Pre = "http://7xozqe.com2.z0.glb.qiniucdn.com/"
  def self.get_img_url
    order = rand(21)
    "#{Pre}test#{order}.jpg"
  end

  TestCampaigns = [
    {:name => "原七大军区善后办任务披露",
     :desc => "这注定是一个载入军史的春天，这必将是一个开新图强的起点：随着习主席和中央军委一声令下，七大军区完成历史使命，五大战区正式组建亮相。",
     :url => "http://mil.sina.cn/zgjq/2016-02-23/detail-ifxprucu3128168.d.html?from=wap"
    },
    {:name => "商务部部长：中国中高收入阶层正在形成",
     :desc => "商务部部长高虎城今天（2月23日）上午在国务院新闻办举行的发布会上表示，中国中高收入阶层正在形成，这个阶层的消费不满足于大众化的需求。因此，商务工作从供给侧发力的一个重点，就是如何满足中高收入阶层个性化、差异化的消费需求，满足他们对品种更多、质量更好、更为安全、购物环境更为舒适的需求",
     :url => "http://news.sina.com.cn/o/2016-02-23/doc-ifxprupc9814419.shtml"
    },
    {:name => "12省份计生新政出台 产假最长180天最短128天",
     :desc => "为全面实施两孩政策，各地相继开始修订地方计生条例，目前，天津、浙江、宁夏等12省份的新计生条例已经出台。经人民网编辑梳理发现，不同省份产 假从最长的180天到最短的128天，可相差近两个月之多。而对于百姓担心的两孩生育相关保障问题，多名专家围绕产儿科和幼儿园建设这两大育儿重点给出建 议，其中，来自北京市第一幼儿园的冯慧燕建议恢复“托儿所”，为全面二胎作保障",
     :url => "http://news.sina.com.cn/c/nd/2016-02-23/doc-ifxprucs6406466.shtml"
    },
    {:name => "村民家中水井打出汽油 加进车里动力十足(图)",
     :desc => "2月1日，西安市临潼区斜口街办代张杨村两户村民从自家水井里打出汽油，经记者实测，加上该油的摩托车、小轿车竟然动力十足。村民在啧啧称奇的同时也不禁对自己的饮用水安全产生了担心。",
     :url => "http://news.sina.com.cn/s/wh/2016-02-23/doc-ifxprucs6417923.shtml"
    },

    {:name => "库克再发备忘录:呼吁司法部撤回破解iPhone裁决",
     :desc => "北京时间2月22日晚间消息，据美国新闻聚合网站BuzzFeed报道，苹果公司(以下简称“苹果”)CEO蒂姆·库克(Tim Cook)周一再次致信员工，呼吁美国司法部撤回法庭之前做出的“要求苹果帮助美国联邦调查局(以下简称“FBI”)解锁iPhone”的裁",
     :url => "http://tech.sina.com.cn/t/2016-02-22/doc-ifxprucu3117549.shtml"
    },
    {:name => "直连大脑的机器手，韧带肌腱一应俱全",
     :desc => "研究人员近日研发出了一款新型机器手，这是目前最接近真实人手的产品，可以模拟出我们双手的一举一动。",
     :url => "http://blog.jobbole.com/97974/"
    },
    {:name => "程序媛往往比程序猿更受认可",
     :desc => "用一句话总结这项最新的学术研究的结论就是，女程序员的代码往往写得比男性更好，而且人们也都知道这一点。",
     :url => "http://blog.jobbole.com/97931/"
    },
    {:name => "刘慈欣谈引力波：未来长期对人类生活无意义",
     :desc => "“在相当长一段时间，引力波将停留在基础科学研究的层面，用来扩展人类知识，加深对宇宙的理解。但对人类的现实生活，我不认为有任何意义。”中国科幻作家刘慈欣23日在接受中新社记者采访时说。",
     :url => "http://tech.sina.com.cn/d/i/2016-02-23/doc-ifxprucs6417664.shtml"
    },

    {:name => "日内瓦车展亮相 Rimac电动超级跑车官图",
     :desc => "日前，来自克罗地亚的超级跑车品牌Rimac发布了旗下电动超级跑车Rimac Concept One的量产版官图，新车将会在今年3月的日内瓦车展首发亮相。",
     :url => "http://auto.sina.com.cn/newcar/h/2016-02-23/detail-ifxprucs6419749.shtml"
    },
    {:name => "回溯时间:引力波能让我们窥见宇宙创生时刻吗？",
     :desc => "爱因斯坦再一次被证明是正确的：正如他在100年前所言，引力场发生的变化的确会像波纹一般在时空之海中泛起涟漪并向外传播。",
     :url => "http://tech.sina.com.cn/d/i/2016-02-23/doc-ifxprucu3124046.shtml"
    },
    {:name => "夕阳照片现“火瀑布”奇观 似熔岩绝壁流泻而下",
     :desc => "一道艳丽夺目的“熔岩”由绝壁流泻而下，形成绝美风景，这便是大自然的杰作――“火瀑布”(Firefall)。",
     :url => "http://slide.tech.sina.com.cn/d/slide_5_453_67295.html"
    },
    {:name => "日媒指责中国渔船在日本专属经济区“爆渔”",
     :desc => "日媒指责中国渔船在日本专属经济区“爆渔”",
     :url => "http://news.sina.com.cn/c/2016-02-23/doc-ifxprupc9824473.shtml"
    },
  ]

  def self.add_test_data(per_budget_type = nil, long = nil)
    if !Rails.env.production?
      u = User.find 84
      per_budget_type = ['post', 'click'].sample    if per_budget_type.blank?
      campaign_attrs = TestCampaigns[rand(12)]
      long = rand(2) == 1                            if long.nil?
      campaign = Campaign.create(:user => u, :budget => (long ? 40 : 3), :per_action_budget => 1, :start_time => Time.now + 2.seconds, :deadline => Time.now + (long ? 24.hours : 1.hours),
      :url => campaign_attrs[:url], :name => campaign_attrs[:name], :description => campaign_attrs[:desc], :img_url => get_img_url, :per_budget_type => per_budget_type)
      campaign.status = 'agreed'
      campaign.save
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
