class UserAddOn < ActiveRecord::Base
  belongs_to :user
  belongs_to :add_on

  validates :user,:add_on,:presence => true

  has_many :payments,  :as => :payable , :dependent => :destroy

  after_create :set_usage,:create_payment

  def set_usage
    update_attributes({expiry: add_on.use_by, charged_amount: add_on.price,count: add_on.count})
  end

  def is_available?
    return false if expiry.present? && expiry < Time.now.utc
    return false if used_count >= count
    true
  end

  def available_count
    count - used_count #count defaults to 1
  end

  def create_payment
    payment = payments.create(
        user_id: user_id,
        amount:  add_on.price,
        orderable_id: add_on.id,
        orderable_type: "AddOn" #need to add credit card details for book keeping only as subscription payments
    )
  end

end