class CampaignAction < ActiveRecord::Base
  belongs_to :campaign
  belongs_to :kol

  scope :likes , -> {where(:action => 'like')}
  scope :hides , -> {where(:action => 'hide')}
end
