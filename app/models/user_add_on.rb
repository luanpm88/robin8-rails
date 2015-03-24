class UserAddOn < ActiveRecord::Base
  belongs_to :user
  belongs_to :add_on

  validates :user,:add_on,:presence => true

  def is_available?
    return false if expiry.present? && expiry < Time.now.utc
    return false if used_count >= available_count
    true
  end


end