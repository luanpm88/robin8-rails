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


  def batch_create
    Subscription.where("next_charge_date < '#{Date,today}'").each do |s|
      begin
        resp = BlueSnap::Subscription.find_last_by_shopper_id(s.shopper_id)
        if resp.present?
          next if s.payments.map(&:bluesnap_subscription_id).include?(resp[:subscription_id].to_i)
          Payment.create!(
              subscription_id: s.id,
              package_id: s.package_id,
              total_amount: resp[:catalog_recurring_charge][:amount], #to be renamed to amount
              user_id: current_user.id,
              order_id: resp[:subscription_id], #to be named bluesnap_subscription_id
              card_last_four_digits: resp[:credit_card][:card_last_four_digits],
              card_type:    resp[:credit_card][:card_type],
              status: resp[:status] #status field to be added
          )
          s.update_attribute(:next_charge_date,Date.parse(resp[:next_charge_date]))
        end
      end
      rescue Exception => e
      next
    end
  end


end
