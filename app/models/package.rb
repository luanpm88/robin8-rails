class Package < ActiveRecord::Base

  has_many :payments

  validates :slug, presence: true
  validates :is_active, presence: true
  validates :price, presence: true
  validates :interval_length, presence: true

end
