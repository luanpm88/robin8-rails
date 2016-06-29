class CampaignActionUrl < ActiveRecord::Base
  belongs_to :campaign

  validates_presence_of :action_url, :campaign_id, :short_url
end
