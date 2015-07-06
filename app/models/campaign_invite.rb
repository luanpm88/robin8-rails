class CampaignInvite < ActiveRecord::Base
  STATUSES = ['', 'A', 'D']
  validates_inclusion_of :status, :in => STATUSES

  belongs_to :campaign
  belongs_to :kol
end
