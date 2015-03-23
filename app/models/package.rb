class Package < ActiveRecord::Base

  has_many :payments
  has_many :subscriptions

  validates :slug, :price, :interval, :sku_id, presence: true

  def monthly_package
    Package.find_by_slug self.slug.gsub('annual','monthly')
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

end
