class UserAddOn < ActiveRecord::Base
  belongs_to :user
  belongs_to :add_on

  validates :user,:add_on,:presence => true
  after_create :set_usage

  def set_usage
    update_attributes({expiry: add_on.use_by, charged_amount: add_on.price,count: add_on.count})
  end

  def is_available?
    return false if expiry.present? && expiry < Time.now.utc
    return false if used_count >= count
    true
  end

  def available_count
    count - used_count #count defaults to 1 no matter of count
  end

end