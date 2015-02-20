class Payment < ActiveRecord::Base

  belongs_to :package
  belongs_to :subscription
  belongs_to :user

  validates :user,:subscription, :package, :card_number, :encrypted_card_number,
            :card_last_four_digits, :card_type, :expiration_month, :expiration_year,
            :security_code, :encrypted_security_code, :charged_amount, :total_amount, presence: true

end
