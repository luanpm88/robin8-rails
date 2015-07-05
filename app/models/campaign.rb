class Campaign < ActiveRecord::Base
  belongs_to :user
  has_many :campaign_invites
  has_many :kols, through: :campaign_invites
  has_many :articles

  has_many :campaign_categories
  has_many :iptc_categories, :through => :campaign_categories
end
