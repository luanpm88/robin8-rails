class Payment < ActiveRecord::Base

  belongs_to :package
  belongs_to :subscription
  belongs_to :user

  validates :user,:subscription, :package, :card_last_four_digits, :card_type,
            :expiration_month, :expiration_year, :charged_amount, :total_amount, presence: true

  after_create :notify_user

  def notify_user
    #send email if required to user about recurring payment
  end

end
