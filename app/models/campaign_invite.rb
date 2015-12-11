class CampaignInvite < ActiveRecord::Base
  include Redis::Objects
  counter :redis_avail_click
  counter :redis_total_click

  STATUSES = ['pending', 'running', 'approved', 'finished', 'rejected']
  validates_inclusion_of :status, :in => STATUSES

  belongs_to :campaign
  belongs_to :kol

  def get_avail_click
    status == 'finished' ? self.avail_click : self.redis_avail_click.value
  end

  def self.generate_share_url(uuid)
    Rails.logger.error.info "-----enter generate share url"
    url = "#{Rails.application.secrets.domain}/campaign_show?uuid=#{uuid}"
    url = ShortUrl.convert url
    Rails.logger.error.info "-----end generate share url --- #{url}"
    return url
  end

  def add_click(valid)
    self.redis_avail_click.increment if valid
    self.redis_total_click.increment
    return true
  end

end
