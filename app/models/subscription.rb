class Subscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :package
  has_many :payments

  validates :user, :package, :underlying_sku_id, :shopper_id, :recurring_amount, :next_charge_date,
            :auto_renew, :charged_amount, :total_amount, presence: true

end
