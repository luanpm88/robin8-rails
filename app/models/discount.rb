class Discount < ActiveRecord::Base
  has_many :user_discounts
  has_many :product_discounts

  validates :code,:expiry,:presence => true
  accepts_nested_attributes_for :user_discounts,:product_discounts

  scope :active, lambda{where(is_active: true).where("expiry > #{Time.now.utc}")}

  def is_global?
    product_discounts.blank? ?  true : false
  end

  def on_product?(product_id)
    product_discounts.where(product_id: product_id).exists? ? true : false
  end

  def on_user?(user_id)
    user_discounts.where(user_id: user_id).exists? ? true : false
  end

end