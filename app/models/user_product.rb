class UserProduct < ActiveRecord::Base
  belongs_to :user
  belongs_to :product
  has_many :payments , :dependent => :destroy

  validates :user,:product, :bluesnap_shopper_id, presence: true

  after_create :create_payment
  before_update :normalize_features

  def normalize_features #has already paid for previous month so just add more features, he will be charged next month for it accordingly.
    if !product_id_was.blank? && product_id_was.to_i != product_id.to_i
      product.features.each do |f|
        product_quota = product.product_features.where(feature_id: f.id).first.quota
        if product.slug == 'smart_release'
          available_count = product_quota
        else
          available_count = product.is_package ? product_quota - user.used_count_by_slug(f.slug) : product_quota
        end

        user.user_features.create!(
            feature_id: f.id,
            product_id: product.id, #for book keeping
            max_count: product.product_features.where(feature_id: f.id).first.quota,
            available_count: available_count < 0 ? 0 : available_count,
            reset_at: product.product_features.where(feature_id: f.id).first.reset_at
        )
      end
    end
  end

  def as_json(options={})
    super(methods: [:product])
  end

  def is_cancelled?
    expiry.blank? ? false : true
  end

  def is_suspended?
    suspended_at.blank? ? false : true
  end

  def cancel!
    errors = BlueSnap::Subscription.destroy(bluesnap_subscription_id,bluesnap_shopper_id,product.sku_id) if user.payments.present? && status != 'C'
    if errors.blank?
      self.update_attributes(expiry: self.next_charge_date, status: "C")
      return true
    end
    return false
  end

  def create_payment
    bluesnap_order = Blue::Order.find(bluesnap_order_id)
    discount = Discount.where(discount_name: bluesnap_order.cart.coupons.coupon).first if bluesnap_order && bluesnap_order.cart && bluesnap_order.cart.try(:coupons).present?
    unless user.locale == 'zh'
      recurring_amount = (discount.present? && discount.is_recurring? ) ? bluesnap_order.post_sale_info.invoices.invoice.financial_transactions.financial_transaction.amount : product.price
      charged_amt =  discount.present? ? product.price - discount.calculate(user,product) : product.price
      tax_rate = (bluesnap_order.cart.tax_rate).to_f
    else
      recurring_amount = (discount.present? && discount.is_recurring? ) ? bluesnap_order.post_sale_info.invoices.invoice.financial_transactions.financial_transaction.amount : product.china_price
      charged_amt =  discount.present? ? product.china_price - discount.calculate(user,product) : product.china_price
      tax_rate = (bluesnap_order.cart.tax_rate).to_f
    end
    if product.is_package? || product.is_recurring?
      bluesnap_subscription = ''
      begin
        if bluesnap_order.cart.cart_item.class == Array
          bluesnap_order.cart.cart_item.each do |i|
            bluesnap_subscription = Blue::Subscription.find(i.url.split("/").last) if i.sku.sku_id.to_i == product.sku_id
          end
        else
          bluesnap_subscription = Blue::Subscription.find(bluesnap_order.cart.cart_item.url.split("/").last)
        end
        if bluesnap_subscription.present?
          update_attributes({bluesnap_subscription_id: bluesnap_subscription.subscription_id ,
                             status: bluesnap_subscription.status,
                             next_charge_date: Date.parse(bluesnap_subscription.next_charge_date),
                             recurring_amount: recurring_amount
                             })

          payment = payments.create(
              product_id: product_id, #need in for bookeeping if user changes package
              amount: charged_amt, # bluesnap_order.post_sale_info.invoices.invoice.financial_transactions.financial_transaction.amount,
              card_last_four_digits:  bluesnap_order.post_sale_info.invoices.invoice.financial_transactions.financial_transaction.credit_card.card_last_four_digits,
              card_type: bluesnap_order.post_sale_info.invoices.invoice.financial_transactions.financial_transaction.credit_card.card_type,
              discount_id: discount.present? ?  discount.id : nil,
              tax: tax_rate > 0 ? (charged_amt / 100 * tax_rate).round(2) : 0,
              currency: unless user.locale == 'zh' then '$' else '¥' end
          )
          return payment
        end
      rescue Exception => e
        return nil
      end
    else
      card_last_four_digits = ""
      card_type = ""
      if bluesnap_order.post_sale_info.invoices.invoice.financial_transactions.financial_transaction.payment_method != "None"
        card_last_four_digits = bluesnap_order.post_sale_info.invoices.invoice.financial_transactions.financial_transaction.credit_card.card_last_four_digits
        card_type = bluesnap_order.post_sale_info.invoices.invoice.financial_transactions.financial_transaction.credit_card.card_type
      end
      payments.create(
          amount: charged_amt, #bluesnap_order.post_sale_info.invoices.invoice.financial_transactions.financial_transaction.amount,
          product_id: product_id,
          card_last_four_digits:  card_last_four_digits,
          card_type:  card_type,
          currency: unless user.locale == 'zh' then '$' else '¥' end,
          tax: tax_rate > 0 ? (charged_amt / 100 * tax_rate).round(2) : 0
          # discount_id: discount.present? ?  discount.id : nil
      )
    end
  end


  def self.process_recurring_invoice
    where("next_charge_date < '#{Date.today}' AND status = 'A'").each do |s|
      begin
        bss = Blue::Subscription.find(s.bluesnap_subscription_id)
        s.update_attributes(status: bss.status,
                            next_charge_date: Date.parse(bss.next_charge_date))

        if bss.status == "A"
          s.payments.create!(
              product_id: s.prduct_id,
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
