class CampaignLike < ActiveRecord::Base
  belongs_to :campaign
  belongs_to :kol

  scope :like , -> {where(:like => true)}
  scope :hide , -> {where(:hide => true)}
end
