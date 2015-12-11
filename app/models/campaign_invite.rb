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
    url = "#{Rails.application.secrets.domain}/campaign_show?uuid=#{uuid}"
    ShortUrl.convert url
    # http://robin8-staging.cn/campaign_show?uuid=eyJjYW1wYWlnbl9pZCI6MTE3LCJrb2xfaWQiOjU5fQ==
  end

  def add_click(valid)
    self.redis_avail_click.increment if valid
    self.redis_total_click.increment
    return true
  end

end
