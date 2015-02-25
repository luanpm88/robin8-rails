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

  def process_initial_invoice
    where("next_charge_date is NULL").each do |s|
      begin
        resp = BlueSnap::Subscription.find_last_by_shopper_id(s.shopper_id)
        if resp.present?
          bss = Blue::Subscription.find(resp[:subscription_id])
          s.update_attributes(bluesnap_subscription_id: bss.subscription_id,
                              status: bss.status,
                              next_charge_date: Date.parse(bss.next_charge_date)) #add bluesnap_subscription_id and status string to subscriptions table
          Payment.create!(
              subscription_id: s.id,
              package_id: s.package_id,
              total_amount:  bss.catalog_recurring_charge.amount, #to be renamed to amount
              user_id: current_user.id,
              card_last_four_digits:  bss.credit_card.card_last_four_digits,
              card_type: bss.credit_card.card_type
          )
        end
      rescue Exception => e
        next
      end
    end
  end



  def process_recurring_invoice
    where("next_charge_date <= #{Date.today} AND status = 'A'").each do |s|
      begin
        resp = BlueSnap::Subscription.find_last_by_shopper_id(s.shopper_id)
        if resp.present?
          bss = Blue::Subscription.find(resp[:subscription_id])
          s.update_attributes(status: bss.status,
                              next_charge_date: Date.parse(bss.next_charge_date)) #add bluesnap_subscription_id and status string to subscriptions table

          if bss.status == "A"
            Payment.create!(
                subscription_id: s.id,
                package_id: s.package_id,
                total_amount:  bss.catalog_recurring_charge.amount, #to be renamed to amount
                user_id: current_user.id,
                card_last_four_digits:  bss.credit_card.card_last_four_digits,
                card_type: bss.credit_card.card_type
            )
          end
        end
      rescue Exception => e
        next
      end
    end
  end


  def batch_suspend
    where("next_charge_date < #{Date.today + 3.days} AND status = ''").each do |s|
      s.update_attribute(:suspended_at: Time.now.utc) #suspended_at field to be added
    end
  end

end
