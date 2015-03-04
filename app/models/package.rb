class Package < ActiveRecord::Base

  has_many :payments
  has_many :subscriptions

  validates :slug, :price, :interval, :sku_id, presence: true\

  def monthly_package
    Package.find_by_slug self.slug.gsub('annual','monthly')
  end

  def get_price

  end

end
