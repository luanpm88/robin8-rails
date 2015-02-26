class Subscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :package
  has_many :payments, dependent: :destroy

  after_create :notify_user

  validates :user, :package, :bluesnap_shopper_id, :recurring_amount, presence: true

  def notify_user
    #send email to user about sucessfully transaction
  end

  def is_cancelled?
    expiry.blank? ? false : true
  end

  def is_suspended?
    suspended_at.blank? ? false : true
  end

  def cancel!
    errors = BlueSnap::Subscription.destroy(self.bluesnap_subscription_id,self.bluesnap_shopper_id,self.package.sku_id) if self.user.payments.present? && self.status != 'C'
    if errors.blank?
      self.update_attributes(expiry: self.next_charge_date, status: "C")
      return true
    end
    return false
  end

  def self.process_initial_invoice
    where("next_charge_date is NULL").each do |s|
      begin
        resp = BlueSnap::Subscription.find_last_by_shopper_id(s.bluesnap_shopper_id)
        if resp.present?
          bss = Blue::Subscription.find(resp[:subscription_id])
          s.update_attributes(bluesnap_subscription_id: bss.subscription_id,
                              status: bss.status,
                              next_charge_date: Date.parse(bss.next_charge_date))
          puts s.errors.full_messages
          Payment.create!(
              subscription_id: s.id,
              package_id: s.package_id,
              amount:  bss.catalog_recurring_charge.amount,
              card_last_four_digits:  bss.credit_card.card_last_four_digits,
              card_type: bss.credit_card.card_type
          )
        end
      rescue Exception => e
        next
      end
    end
  end


  def self.process_recurring_invoice
    where("next_charge_date < '#{Date.today}' AND status = 'A'").each do |s|
      begin
        bss = Blue::Subscription.find(s.bluesnap_subscription_id)
        s.update_attributes(status: bss.status,
                            next_charge_date: Date.parse(bss.next_charge_date))

        if bss.status == "A"
          Payment.create!(
              subscription_id: s.id,
              package_id: s.package_id,
              amount:  bss.catalog_recurring_charge.amount,
              card_last_four_digits:  bss.credit_card.card_last_four_digits,
              card_type: bss.credit_card.card_type
          )
        end
      rescue Exception => e
        next
      end
    end
  end

  def self.batch_suspend
    where("next_charge_date < '#{Date.today + 3.days}' AND status = 'D'").each do |s|
      bss = Blue::Subscription.find(s.bluesnap_subscription_id)
      if bss.status == "A"
        s.update_attributes(status: bss.status) #activate again
      else
        s.update_attribute(:suspended_at, Time.now.utc) #cancel acount
      end
    end
  end

end
