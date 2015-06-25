class CampaignInvite < ActiveRecord::Base
  belongs_to :campaign
  belongs_to :kol
end
