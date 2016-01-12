class CampaignInvite < ActiveRecord::Base
  include Redis::Objects
  counter :redis_avail_click
  counter :redis_total_click

  STATUSES = ['pending', 'running', 'approved', 'finished', 'rejected']
  ImgStatus = ['pending','passed', 'rejected']
  validates_inclusion_of :status, :in => STATUSES

  belongs_to :campaign
  belongs_to :kol
  scope :passed, -> {where(:img_status => 'passed')}

  def screenshot_pass
    campaign = self.campaign
    if campaign.status == 'executed' && self.img_status != 'passed'
      self.update_column(:img_status, 'passed')
      Rails.logger.info "-------- screenshot_check_pass:  ---cid:#{campaign.id}--"
    end
  end

  def screenshot_reject
    campaign = self.campaign
    if campaign.status == 'executed' && self.img_status != 'passed'
      self.img_status = 'rejected'
      self.save
      Rails.logger.info "-------- screenshot_check_rejected: ---cid:#{campaign.id}--"
    end
  end

  def reupload_screenshot(img)
    self.img_status = 'pending'
    self.screenshot = img
    self.save
    Rails.logger.info "-------- reupload_screenshot: ---cid:#{campaign.id}--"
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

  def add_click(valid)
    self.redis_avail_click.increment if valid
    self.redis_total_click.increment
    return true
  end

  def generate_uuid_and_share_url
    uuid = Base64.encode64({:campaign_id => self.campaign_id, :kol_id=> self.kol_id}.to_json).gsub("\n","")
    self.uuid = uuid
    self.share_url = CampaignInvite.generate_share_url(uuid)
    self.save
  end

  def self.create_invite(campaign_id, kol_id)
    return if CampaignInvite.exists?(:kol_id => kol_id, :campaign_id => campaign_id)
    invite = CampaignInvite.new
    invite.status = 'pending'
    invite.campaign_id = campaign_id
    invite.kol_id = kol_id
    invite.save!
  end

end
