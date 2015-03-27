class Payment < ActiveRecord::Base

  belongs_to :package
  belongs_to :subscription
  validates :payable_id, :amount, presence: true

  belongs_to :payable, :polymorphic => true
  belongs_to :orderable, :polymorphic => true

  after_create :notify_user

  def notify_user
    #send email if required to user about recurring payment
  end


end
