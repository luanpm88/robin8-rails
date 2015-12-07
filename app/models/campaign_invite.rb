class CampaignInvite < ActiveRecord::Base
  include Redis::Objects
  counter :redis_avail_click
  counter :redis_total_click

  # A approved
  # D declined
  # N
  # F finish
  STATUSES = ['', 'A', 'D', 'N', 'F']

  validates_inclusion_of :status, :in => STATUSES

  belongs_to :campaign
  belongs_to :kol

  def self.generate_share_url(uuid)
    "#{Rails.application.secrets.domain}/campaign_show?uuid=#{uuid}"
  end

  def add_click(valid)
    self.redis_avail_click.increment if valid
    self.redis_total_click.increment
  end

end
