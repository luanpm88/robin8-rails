class Subscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :package
  has_many :payments

  after_create :notify_user

  validates :user, :package, :shopper_id, :recurring_amount, :next_charge_date,
            :auto_renew, :charged_amount, :total_amount, presence: true

  def notify_user
    #send email to user about sucessfully transaction
  end

end
