class CampaignInvite < ActiveRecord::Base
  include Redis::Objects
  include Concerns::InviteStatus
  counter :redis_avail_click        #有效计费点击
  counter :redis_total_click        #所有点击
  counter :redis_real_click         #所有有效点击(含活动结束后)
  counter :redis_new_income      #unit is cent
  lock :settle


  STATUSES = ['pending', 'running', 'applying', 'approved', 'finished', 'rejected', "settled"]
  CommonRejectedReason = ["朋友圈截图错误", "朋友圈截图不完整", "活动保留时间不足30分钟", "活动评论有诱导嫌疑", "活动含诱导点击文字", "活动被设置分组了","朋友圈过多活动影响效果","系统检测到有作弊嫌疑","活动一次点击都没有"]
  # observer_status 0 表示 未计算, 1 表示 正常, 2 表示 存在作弊嫌疑
  ImgStatus = ['pending','passed', 'rejected']
  OcrStatus = ['pending', 'passed','failure']
  OcrDetails = {"unfound" => "抱歉，没有发现指定的转发活动", "time" => '内容发布时间必须在30分钟前', "group" => '请勿设置好友分组', "owner" => '非您本人发布的活动'}
  # Ocr_detail  'unfound','time','group','owner']
  #  ocr_detail_text:
  UploadScreenshotWait = Rails.env.production? ? 30.minutes : 1.minutes
  CanAutoCheckInterval = Rails.env.production? ? 3.hours : 2.minutes

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
  scope :should_reject, -> {where("img_status != 'passed'")}
  scope :verifying, -> {where("(status = 'finished' and img_status != 'passed') or (status = 'approved' and screenshot is not null)")}
  scope :settled, -> {where(:status => 'settled')}
  # 已完成的概念改成  已审核通过（活动没结束 状态还是finished）或已结算（含结算失败）
  scope :completed, -> {where("img_status='passed'  or status = 'rejected'")}

  scope :today_approved, -> {where(:approved_at => Time.now.beginning_of_day..Time.now.end_of_day)}
  scope :approved_by_date, -> (date){where(:approved_at => date.beginning_of_day..date.end_of_day)}
  scope :not_rejected, -> {where("campaign_invites.status != 'rejected'")}
  scope :waiting_upload, -> {where("(img_status = 'rejected' or screenshot is null) and status != 'running' and status != 'rejected' and status != 'settled'")}
  scope :can_day_settle, -> {where("(status='finished' or status='approved') and (img_status='passed' or (screenshot is not null and upload_time < '#{CanAutoCheckInterval.ago}'))")}
  # scope :can_auto_passed, -> {where(:status => ['approved', 'finished']).where("screenshot is not null and upload_time > '#{1.days.ago}'")}
  delegate :name, to: :campaign
  def upload_start_at
    if  campaign.is_recruit_type? || campaign.is_post_type?
      approved_at.blank? ? nil : approved_at +  UploadScreenshotWait
    else
      approved_at.blank? ? nil : approved_at
    end
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
      (status == 'approved' || status == 'finished') && img_status != 'passed' &&  Time.now > self.upload_start_at &&  Time.now < self.upload_end_at
    end
  end

  # 进行中的活动 审核通过时  仅仅更新它状态
  # 已结束的活动 审核通过时   更新图片审核状态 + 立即对该kol结算
  def screenshot_pass
    return false if self.img_status == 'passed' || self.status == 'settled'  ||  self.status == 'rejected'
    if campaign.status == 'executing'
      self.update_attributes(:img_status => 'passed', :check_time => Time.now)
    elsif campaign.status == 'executed'
      self.update_attributes!(:img_status => 'passed', :status => 'finished', :check_time => Time.now)
      self.settle
    end
    Message.new_check_message('screenshot_passed', self, campaign)
  end

  #审核拒绝
  def screenshot_reject rejected_reason=nil
    campaign = self.campaign
    if (campaign.status == 'executed' || campaign.status == 'executing') && self.img_status != 'passed'
      self.update_attributes(:img_status => 'rejected', :reject_reason => rejected_reason, :check_time => Time.now)
      Message.new_check_message('screenshot_rejected', self, campaign)
      Rails.logger.info "----kol_id:#{self.kol_id}---- screenshot_check_rejected: ---cid:#{campaign.id}--"
    end
  end

  def permanent_reject rejected_reason=nil
    return if self.status == 'settled' || self.status == 'rejected'  || self.img_status == 'passed'
    self.with_lock do
      kol_avail_click = self.get_avail_click
      self.update_columns(:avail_click => 0, :status => 'rejected', :img_status => 'rejected', :reject_reason => rejected_reason, :check_time => Time.now)
      self.redis_avail_click.reset
      CampaignShow.where(:campaign_id => self.campaign_id, :kol_id => self.kol_id, :status => 1).update_all(:status => 0, :remark => 'permanent_reject')
      self.campaign.redis_avail_click.decrement(kol_avail_click.to_i)
      if self.campaign.status == 'executed' && self.campaign.finish_remark == 'fee_end' && ['cpi', 'cpa', 'click'].include?(self.campaign.per_budget_type)
        avail_kol_ids = CampaignInvite.where(:campaign_id => self.campaign_id, :status => ['finished', 'settled']).collect{|t| t.kol_id}
        wait_restore_shows = CampaignShow.where(:campaign_id => self.campaign_id, :kol_id => avail_kol_ids, :status => 0, :remark => CampaignShow::CampaignExecuted).order("id asc").limit(kol_avail_click)
        Rails.logger.transaction.info "=======aaa===size:#{wait_restore_shows.size}"
       #TODO group by
        wait_restore_shows.each do |wait_restore_show|
          Rails.logger.transaction.info wait_restore_show.inspect
          invite = CampaignInvite.find_by(:campaign_id => wait_restore_show.campaign_id, :kol_id => wait_restore_show.kol_id)
          Rails.logger.transaction.info invite.inspect
          if invite
            invite.redis_avail_click.increment
            invite.increment!(:avail_click, 1)
          end
        end
        Rails.logger.transaction.info "=======campaign.redis_avail_click"
        self.campaign.redis_avail_click.increment(wait_restore_shows.size)
         Rails.logger.transaction.info "=======bbb===size:#{wait_restore_shows.size}"
        wait_restore_shows.update_all(:status => 1, :remark => 'restore')
      end
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
    elsif campaign.is_invite_type?
      self.price
    else
      campaign.get_per_action_budget(false).round(2) rescue 0
    end
  end

  def add_click(valid, remark = nil, only_increment_avail = false)
    self.redis_avail_click.increment if valid
    self.redis_real_click.increment if valid || remark == CampaignShow::CampaignExecuted
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
  def self.schedule_day_settle(async = true)
    Rails.logger.settle.info "----schedule_day_settle---async:#{async}"
    if async
      CampaignDaySettleWorker.perform_async
    else
      if Rails.env.production?
        transaction_time = Date.today.beginning_of_day - 1.minutes
      else
        transaction_time = Time.now
      end
      campaign_ids = Campaign.where(:status => ['executing', 'executed'], :per_budget_type => ['cpi', 'click', 'cpa']).collect{|t| t.id}
      return if campaign_ids.size == 0
      ids = CampaignInvite.where(:campaign_id => campaign_ids).can_day_settle.collect{|t| t.id}
      Rails.logger.settle.info "----schedule_day_settle---day_settle:#{ids}--#{transaction_time}"
      #对审核通过的自动结算
      CampaignInvite.where(:campaign_id => campaign_ids).can_day_settle.each do |invite|
        invite.settle(true, transaction_time)
      end
    end
  end

  def settle(auto = false, transaction_time = Time.now)
    Rails.logger.transaction.info "----settle---campaign_invite_id:#{self.id}---auto:#{auto}"
    return if self.status == 'rejected'
    self.settle_lock.lock  do
      if ['cpi', 'click', 'cpa'].include? self.campaign.per_budget_type
        next if (self.observer_status == 2 || self.get_avail_click > 30 || self.get_total_click > 100) && auto == true
        #1. 先自动审核通过
        self.update_columns(:img_status => 'passed', :auto_check => true) if auto == true && self.img_status == 'pending' && self.screenshot.present? && self.upload_time < CanAutoCheckInterval.ago
        campaign_shows = CampaignShow.invite_need_settle(self.campaign_id, self.kol_id, transaction_time)
        if campaign_shows.size > 0
          credits =  campaign_shows.size * self.campaign.get_per_action_budget(false)
          transaction = self.kol.income(credits, 'campaign', self.campaign, self.campaign.user, transaction_time)
          campaign_shows.update_all(:transaction_id => transaction.id)
          Rails.logger.transaction.info "---settle  kol_id:#{self.kol.id}-----invite_id:#{self.id}--tid:#{transaction.id}-credits:#{credits}---#avail_amount:#{self.kol.avail_amount}-"
        end
      elsif ['recruit', 'post'].include?(self.campaign.per_budget_type) && self.status == 'finished' && self.img_status == 'passed'
        self.kol.income(self.campaign.get_per_action_budget(false), 'campaign', self.campaign, self.campaign.user)
        Rails.logger.transaction.info "---settle kol_id:#{self.kol.id}----- cid:#{campaign.id}---fee:#{campaign.get_per_action_budget(false)}---#avail_amount:#{self.kol.avail_amount}-"
      elsif self.campaign.is_invite_type? && self.status == 'finished' && self.img_status == 'passed'
        if self.kol.kol_role == "mcn_big_v"
          settle_kol = self.kol.agent  rescue nil
           Rails.logger.transaction.info "====invite cmapaign kol_id:#{self.kol.id} not found mcn agent"
        else
          settle_kol = self.kol
        end
        next if  settle_kol.blank?
        settle_kol.income(self.price, 'campaign', self.campaign, self.campaign.user)
        Rails.logger.transaction.info "---settle settle_kol_id:#{settle_kol.id}----- cid:#{campaign.id}---fee:#{self.price}---#avail_amount:#{settle_kol.avail_amount}-"
      end
      self.update_column(:status, 'settled') if self.status == 'finished' && self.img_status == 'passed'
    end
  end

end
