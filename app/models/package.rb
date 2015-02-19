class Package < ActiveRecord::Base

  has_may :payments

  validates :slug, presence: true
  validates :is_active, presence: true
  validates :price, presence: true
  validates :type, presence: true

end
