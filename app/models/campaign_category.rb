class CampaignCategory < ActiveRecord::Base
  belongs_to :campaign
  belongs_to :iptc_category
end
