class Discount < ActiveRecord::Base
  has_many :user_discounts
  has_many :product_discounts
  has_many :products,:through => :product_discounts
  has_many :users,:through => :user_discounts

  validates :code,:expiry,:percentage, :presence => true
  validates :code,:uniqueness => true

  accepts_nested_attributes_for :user_discounts,:product_discounts

  scope :active, lambda{where(is_active: true).where("expiry > '#{Time.now.utc}'")}

  def is_global?
    (product_discounts.blank? && user_discounts.blank?) ?  true : false
  end

  def only_on_product?(product_id)
    (product_discounts.where(product_id: product_id).exists? && user_discounts.blank?) ? true : false
  end

  def on_user_and_product?(user_id,product_id)
    (user_discounts.where(user_id: user_id).exists?  && (product_discounts.blank? || product_discounts.where(product_id: product_id).exists? ) )  ? true : false
  end

  def calculate(user,product)
    product.price - (product.price * ((100-percentage)/100))
  end

  # def is_user_only_discount?
  #   user_discounts.blank? ? false : true
  # end

end