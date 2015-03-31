class Product < ActiveRecord::Base

  has_many :payments
  has_many :subscriptions

  has_many :product_features,:dependent => :destroy
  has_many :features,:through => :product_features
  validates :slug, :price, :sku_id, presence: true

  scope :active, lambda{where(is_active: true)}
  scope :package, lambda{where(is_package: true)}
  scope :add_on, lambda{where(is_package: false)}

  def monthly_package
    Product.find_by_slug self.slug.gsub('annual','monthly')
  end

  def get_price

  end

  def properties
    plans = YAML.load_file(Rails.root.join('config', 'subscription_plans.yml'))
    plan = plans["plans"][self.slug.split('-')[0]]
    plan
  end

  def as_json(options={})
    super(methods: [:properties])
  end

  def is_recurring?
    interval.to_i >= 30 ? true : false #non recurring have interval as 0 or nil
  end

end
