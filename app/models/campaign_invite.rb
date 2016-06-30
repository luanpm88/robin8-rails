class CampaignInvite < ActiveRecord::Base
  include Redis::Objects
  include Concerns::InviteStatus
  counter :redis_avail_click        #有效计费点击
  counter :redis_total_click        #所有点击
  counter :redis_real_click         #所有有效点击(含活动结束后)
  counter :redis_new_income      #unit is cent


  STATUSES = ['pending', 'running', 'applying', 'approved', 'finished', 'rejected', "settled"]
  CommonRejectedReason = ["不在朋友圈/该条信息详细页", "截图不完整", "不足30分钟", "评论涉嫌欺诈", "含有诱导点击文字", "分组可见", "朋友圈过多悬赏活动，影响效果"]
  # observer_status 0 表示 未计算, 1 表示 正常, 2 表示 存在作弊嫌疑
  ImgStatus = ['pending','passed', 'rejected']
  OcrStatus = ['pending', 'passed','failure']
  OcrDetails = {"unfound" => "抱歉，没有发现指定的转发活动", "time" => '内容发布时间必须在30分钟前', "group" => '请勿设置好友分组', "owner" => '非您本人发布的活动'}
  # Ocr_detail  'unfound','time','group','owner']
  #  ocr_detail_text:
  UploadScreenshotWait = Rails.env.production? ? 30.minutes : 1.minutes

  validates_inclusion_of :status, :in => STATUSES
  validates_uniqueness_of :uuid

  belongs_to :campaign_apply
  belongs_to :campaign
  belongs_to :kol
  scope :unrejected, -> {where("campaign_invites.status != 'rejected'")}
  # scope :running, -> {where(:status => 'running')}

  # 已接受且上传截图 放入待审核
  scope :approved, -> {where(:status => 'approved').where("screenshot is null ")}
  scope :passed, -> {where(:img_status => 'passed')}
  scope :verifying_or_approved,  -> {where("status = 'finished' or status = 'approved'")}
  scope :verifying, -> {where("(status = 'finished' and img_status != 'passed') or (status = 'approved' and screenshot is not null)")}
  scope :settled, -> {where(:status => 'settled')}
  # 已完成的概念改成  已审核通过（活动没结束 状态还是finished）或已结算（含结算失败）
  scope :completed, -> {where("img_status='passed'  or status = 'rejected'")}

  scope :today_approved, -> {where(:approved_at => Time.now.beginning_of_day..Time.now.end_of_day)}
  scope :approved_by_date, -> (date){where(:approved_at => date.beginning_of_day..date.end_of_day)}
  scope :not_rejected, -> {where("campaign_invites.status != 'rejected'")}
  scope :waiting_upload, -> {where("(img_status = 'rejected' or screenshot is null) and status != 'running' and status != 'rejected' and status != 'settled'")}
  scope :can_day_settle, -> {where("(status='finished' or status='approved') and (img_status='passed' or (screenshot is not null and upload_time > '#{1.days.ago}')")}
  # scope :can_auto_passed, -> {where(:status => ['approved', 'finished']).where("screenshot is not null and upload_time > '#{1.days.ago}'")}
  delegate :name, to: :campaign
  def upload_start_at
     approved_at.blank? ? nil : approved_at +  UploadScreenshotWait
  end

  def upload_end_at
    self.campaign.upload_screenshot_deadline
  end

  def upload_interval_time
    return interval_time(Time.now, upload_start_at)
  end

  def start_upload_screenshot
    Time.now >  upload_start_at  rescue false
  end

  def can_upload_screenshot
    if campaign.is_recruit_type?
      status == 'finished' && img_status != 'passed' && Time.now >= self.campaign.start_time  &&  Time.now < self.upload_end_at
    else
      (status == 'approved' || status == 'finished') && img_status != 'passed' && Time.now > upload_start_at &&  Time.now < self.upload_end_at
    end
  end

  # 进行中的活动 审核通过时  仅仅更新它状态
  # 已结束的活动 审核通过时   更新图片审核状态 + 立即对该kol结算
  def screenshot_pass
    return false if self.img_status == 'passed' || self.status == 'settled'  ||  self.status == 'rejected'
    campaign = self.campaign
    kol = self.kol
    if campaign.status == 'executing'
      self.update_attributes(:img_status => 'passed', :check_time => Time.now)
    elsif campaign.status == 'executed'
      ActiveRecord::Base.transaction do
        self.update_attributes!(:img_status => 'passed', :status => 'settled', :check_time => Time.now)
        if campaign.is_recruit_type?  || campaign.is_post_type?
          kol.income(campaign.get_per_action_budget(false), 'campaign', campaign, campaign.user)
          Rails.logger.transaction.info "---kol_id:#{kol.id}----- screenshot_check_pass: - forward--cid:#{campaign.id}---fee:#{campaign.get_per_action_budget(false)}---#avail_amount:#{kol.avail_amount}-"
        else
          # 自动审核
        end
      end
    end
    Message.new_check_message('screenshot_passed', self, campaign)
  end

  def screenshot_reject rejected_reason=nil
    campaign = self.campaign
    if (campaign.status == 'executed' || campaign.status == 'executing') && self.img_status != 'passed'
      self.update_attributes(:img_status => 'rejected', :reject_reason => rejected_reason, :check_time => Time.now)
      #审核拒绝
      Message.new_check_message('screenshot_rejected', self, campaign)
      Rails.logger.info "----kol_id:#{self.kol_id}---- screenshot_check_rejected: ---cid:#{campaign.id}--"
    end
  end

  def reupload_screenshot(img_url)
    self.update_attributes(:img_status => 'pending', :screenshot => img_url, :reject_reason => nil, :upload_time => Time.now )
  end

  def get_total_click
    self.redis_total_click.value   rescue self.total_click
  end

  def get_avail_click
    status == 'finished' ? self.avail_click : (self.redis_avail_click.value  rescue 0)
  end

  def self.origin_share_url(uuid)
    "#{Rails.application.secrets.domain}/campaign_show?uuid=#{uuid}"          rescue nil
  end

  def self.generate_share_url(uuid)
    ShortUrl.convert origin_share_url(uuid)
  end

  def origin_share_url
    url = "#{Rails.application.secrets.domain}/campaign_show?uuid=#{self.uuid}"
    $weixin_client.authorize_url url
  end

  def earn_money
    return 0 if self.new_record?
    campaign = self.campaign
    return 0.0 if campaign.blank?
    if campaign.is_click_type? or campaign.is_cpa_type? || campaign.is_cpi_type?
      (get_avail_click * campaign.get_per_action_budget(false)).round(2)       rescue 0
    else
      campaign.get_per_action_budget(false).round(2) rescue 0
    end
  end

  def add_click(valid, remark = nil, only_increment_avail = false)
    self.redis_avail_click.increment if valid
    self.redis_real_click.increment if valid || remark == 'campaign_had_executed'
    self.redis_total_click.increment   if only_increment_avail == false
    return true
  end

  def approve
    uuid = Base64.encode64({:campaign_id => self.campaign_id, :kol_id => self.kol_id}.to_json).gsub("\n","")
    self.update_attributes(:approved_at => Time.now, :status => 'approved', :uuid => uuid, :share_url => CampaignInvite.generate_share_url(uuid))
  end

  def tag
    return nil if  self.campaign.blank?
    if campaign.is_red
      return 'red'
    elsif is_invited
      return 'invite'
    elsif campaign.is_sprint
      return 'sprint'
    elsif campaign.is_new
      return campaign.per_budget_type
    else
      nil
    end
  end

  def get_ocr_detail
    return nil if self.ocr_detail.blank?
    details = []
    self.ocr_detail.split(",").each do |item_key|
      details << OcrDetails[item_key]
    end
    details.join(",")
  end

  def self.get_click_info(kol_id)
    invites =  CampaignInvite.where(:kol_id => kol_id).where("status != 'running' and status != 'applying'")
    invite_count = invites.count
    real_click_count = invites.collect{|t| t.redis_real_click.value }.sum
    return  [invite_count, real_click_count]
  end

  def campaign_type
    case self.campaign.per_budget_type
    when 'click'
      return '点击'
    when 'post'
      return '转发'
    when 'recruit'
      return "招募"
    when 'cpa'
      return 'cpa'
    end
    return self.campaign.per_budget_type
  end

  def campaign_observer_status
    case observer_status
    when 0
      "未统计"
    when 1
      "正常"
    when 2
      "有作弊嫌疑"
    end
  end

  #campaign_invite (status =='approved' || status == 'finished') && img_status == 'passed'   需要结算，但是status == 'finished' 结算后需要
  def self.day_settle(async = true)
    if async
      CampaignDaySettleWorker.perform_async()
    else
      if Rails.env.production?
        deadline = Date.today.beginning_of_day - 1.minutes
      else
        deadline = Time.now
      end
      #campaign.is_post_type? || campaign.is_recruit_type?  origin logic
      campaign_ids = Campaign.where(:status => ['executing', 'executed'], :per_budget_type => ['cpi', 'post', 'click', 'cpa']).collect{|t| t.id}
      return if campaign_ids.size == 0
      #cpi post click campaign 超过一天的截图自动审核通过
      CampaignInvite.where(:camaign_id => campaign_ids).can_auto_passed.update_all(:status => 'passed', :auto_check => true)
      #对审核通过的自动结算
      CampaignInvite.where(:campaign_id => campaign_ids).need_day_settle.each do |invite|

      end
    end
  end

  def settle(auto = true)
    return if self.status == 'settle' || self.status == 'rejected'
    CampaignInvite.transaction do
      if ['cpi', 'post', 'click', 'cpa'].include? self.campaign.per_budget_type
        #1. 先自动审核通过
        self.update_column(:status => 'passed', :auto_check => true) if auto == true && self.img_status == 'pending' && self.upload_time > 1.days.ago
        campaign_shows = CampaignShow.invite_need_settle(self.campaign_id, self.kol_id, deadline)
        credits =  campaign_shows.size * self.campaign.get_per_action_budget(false)
        transaction = self.kol.income(credits, 'campaign', self.campaign, self.campaign.user)
        campaign_shows.update_all(:transaction_id => transaction.id)
        self.update_column(:status, 'settled') if self.status == 'finished' && self.img_status == 'passed'
        Rails.logger.transaction.info "---day_settle  kol_id:#{self.kol.id}-----invite_id:#{self.id}--tid:#{transaction.id}-credits:#{credits}---#avail_amount:#{self.kol.avail_amount}-"
      else

      end
    end
  end

end
