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

  def is_cancelled?
    expiry.blank? ? false : true
  end

  def is_suspended?
    suspended_at.blank? ? false : true
  end

  def batch_create
    where("next_charge_date is NULL").each do |s|
      begin
        resp = BlueSnap::Subscription.find_last_by_shopper_id(s.shopper_id)
        if resp.present?
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
      rescue Exception => e
        next
      end
    end
  end


  def batch_suspend
    where("next_charge_date < #{Date.today + 3.days}").each do |s|
      s.update_attribute(:suspended_at: Time.now.utc) #suspended_at field to be added
    end
  end

end
