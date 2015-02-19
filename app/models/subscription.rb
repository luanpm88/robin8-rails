class Subscription < ActiveRecord::Base
  belongs_to :user
  has_many :payments

  validates :user, presence: true
  validates :underlying_sku_id, presence: true
  validates :shopper_id, presence: true
  validates :recurring_amount, presence: true
  validates :recurring_currency, presence: true
  validates :next_charge_date, presence: true
  validates :auto_renew, presence: true
  validates :security_code, presence: true
  validates :encrypted_security_code, presence: true
  validates :charged_amount, presence: true
  validates :total_amount, presence: true

end
