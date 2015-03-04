class Payment < ActiveRecord::Base

  belongs_to :package
  belongs_to :subscription
  validates :subscription_id, :package, :card_last_four_digits, :card_type, :amount, presence: true

  after_create :notify_user

  def notify_user
    #send email if required to user about recurring payment
  end


  # def self.create_recurring_payments
  #   Subscription.where("next_charge_date < '#{Date.today}'").each do |s|
  #     begin
  #         bss = Blue::Subscription.find(s.bluesnap_subscription_id)
  #         s.update_attributes(status: bss.status,
  #                             next_charge_date: Date.parse(bss.next_charge_date))
  #         Payment.create!(
  #             subscription_id: s.id,
  #             package_id: s.package_id,
  #             amount:  bss.catalog_recurring_charge.amount,
  #             card_last_four_digits:  bss.credit_card.card_last_four_digits,
  #             card_type: bss.credit_card.card_type
  #         )
  #     rescue Exception => e
  #       next
  #     end
  #   end
  # end


end
