class Payment < ActiveRecord::Base

  belongs_to :package
  belongs_to :subscription
  belongs_to :user

  validates :user, presence: true
  validates :subscription, presence: true
  validates :package, presence: true
  validates :card_number, presence: true
  validates :encrypted_card_number, presence: true
  validates :card_last_four_digits, presence: true
  validates :card_type, presence: true
  validates :expiration_month, presence: true
  validates :expiration_year, presence: true
  validates :security_code, presence: true
  validates :encrypted_security_code, presence: true
  validates :charged_amount, presence: true
  validates :total_amount, presence: true

end
