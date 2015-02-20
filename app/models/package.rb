class Package < ActiveRecord::Base

  has_many :payments
  has_many :subscriptions

  validates :slug, :price, :interval, presence: true
end
