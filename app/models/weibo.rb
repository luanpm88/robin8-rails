class Weibo < ActiveRecord::Base
  has_many :campaign_invites
  has_many :campaigns, :through => :campaign_invites
end
