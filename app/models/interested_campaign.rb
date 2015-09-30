class InterestedCampaign < ActiveRecord::Base
  belongs_to :kol
  belongs_to :user
  belongs_to :campaign
end
