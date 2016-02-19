class CampaignInvite < ActiveRecord::Base
  include Redis::Objects
  counter :redis_avail_click
  counter :redis_total_click
  counter :redis_new_income      #unit is cent


  STATUSES = ['pending', 'running', 'approved', 'finished', 'rejected', "settled"]
  ImgStatus = ['pending','passed', 'rejected']
  UploadScreenshotWait = 30.minutes

  validates_inclusion_of :status, :in => STATUSES

  belongs_to :campaign
  belongs_to :kol
  scope :unrejected, -> {where("campaign_invites.status != 'rejected'")}
  scope :running, -> {where(:status => 'running')}
  scope :approved, -> {where(:status => 'approved')}
  scope :passed, -> {where(:img_status => 'passed')}
  scope :verifying, -> {where(:status => 'finished').where.not(:img_status => 'passed')}
  scope :settled, -> {where(:status => 'settled')}

  scope :today_approved, -> {where(:approved_at => Time.now.beginning_of_day..Time.now.end_of_day)}

  def upload_start_at
     approved_at.blank? ? nil : approved_at +  UploadScreenshotWait
  end

  def upload_end_at
    self.campaign.upload_screenshot_deadline
  end

  def upload_interval_time
    return interval_time(Time.now, upload_start_at)
  end


  def can_upload_screenshot
    return  ((status == 'approved' || status == 'finished') && img_status != 'passed' && Time.now > upload_start_at &&  \
      Time.now < self.upload_end_at)
  end

  def screenshot_pass
    campaign = self.campaign
    kol = self.kol
    if (campaign.status == 'executed' || campaign.status == "executing") && self.img_status != 'passed'
      ActiveRecord::Base.transaction do
        self.status = 'settled'
        self.img_status = 'passed'
        self.save!
        if campaign.is_click_type?
          kol.income(self.avail_click * campaign.per_action_budget, 'campaign', campaign, campaign.user)
          Rails.logger.transaction.info "---kol_id:#{kol.id}----- screenshot_check_pass: -click--cid:#{campaign.id}---fee:#{self.avail_click * campaign.per_action_budget}---#avail_amount:#{kol.avail_amount}-"
        else
          kol.income(campaign.per_action_budget, 'campaign', campaign, campaign.user)
          Rails.logger.transaction.info "---kol_id:#{kol.id}----- screenshot_check_pass: - forward--cid:#{campaign.id}---fee:#{campaign.per_action_budget}---#avail_amount:#{kol.avail_amount}-"
        end
      end
    end
  end

  def screenshot_reject
    campaign = self.campaign
    if (campaign.status == 'executed' || campaign.status == 'executing') && self.img_status != 'passed'
      self.img_status = 'rejected'
      self.save
      Rails.logger.info "----kol_id:#{self.kol_id}---- screenshot_check_rejected: ---cid:#{campaign.id}--"
    end
  end

  def reupload_screenshot(img)
    self.img_status = 'pending'
    self.screenshot = img
    self.save
    Rails.logger.info "---kol_id:#{self.kol_id}----- reupload_screenshot: ---cid:#{campaign.id}--"
  end

  def get_total_click
    self.redis_total_click.value   rescue self.total_click
    # status == 'finished' ? self.total_click : self.redis_total_click.value
  end

  def get_avail_click
    status == 'finished' ? self.avail_click : self.redis_avail_click.value
  end

  def self.origin_share_url(uuid)
    "#{Rails.application.secrets.domain}/campaign_show?uuid=#{uuid}"          rescue nil
  end

  def self.generate_share_url(uuid)
    ShortUrl.convert origin_share_url(uuid)
  end

  def earn_money
    campaign = self.campaign
    return 0.0 if campaign.blank?
    if campaign.is_click_type?
      (get_avail_click * campaign.per_action_budget).round(2)       rescue 0
    else
      campaign.per_action_budget.round(2) rescue 0
    end
  end

  def reset_new_income
    self.redis_new_income.reset
  end

  def bring_income(campaign)
    if  campaign.is_click_type?
      #记录新收入
      self.redis_new_income.incr(campaign.per_action_budget * 100)
      #发送新收入消息
      Message.new_income(self,campaign)
    end
  end

  def add_click(valid, campaign = nil)
    self.redis_avail_click.increment if valid
    self.redis_total_click.increment
    bring_income(campaign) if valid &&  campaign
  end

  def generate_uuid_and_share_url
    uuid = Base64.encode64({:campaign_id => self.campaign_id, :kol_id=> self.kol_id}.to_json).gsub("\n","")
    self.uuid = uuid
    self.share_url = CampaignInvite.generate_share_url(uuid)
    self.save
  end

  def self.create_invite(campaign_id, kol_id, status = 'pending')
    # return if CampaignInvite.exists?(:kol_id => kol_id, :campaign_id => campaign_id)
    invite = CampaignInvite.new
    invite.status = status
    invite.campaign_id = campaign_id
    invite.kol_id = kol_id
    invite.save(validate: false)
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
      return 'new'
    else
      nil
    end
  end
end
