class Campaign < ActiveRecord::Base
  belongs_to :user
  has_many :campaign_invites
  has_many :kols, through: :campaign_invites
  has_many :articles
end
