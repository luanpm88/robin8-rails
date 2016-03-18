class CampaignActionUrl < ActiveRecord::Base
  belongs_to :campaign

  validates_presence_of :action_url, :campaign_id
  validates_format_of :action_url, :with => URI::regexp(%w(http https))

end
