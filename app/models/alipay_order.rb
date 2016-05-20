class AlipayOrder < ActiveRecord::Base
  STATUS = %w(pending paid)

  validates :trade_no, presence: true, uniqueness: true
  validates :credits, presence: true
  validates :credits, numericality: { only_integer: true, greater_than_or_equal_to: 500 }
  validates_inclusion_of :status, :in => STATUS

  belongs_to :user

  STATUS.each do |status|
    define_method "#{status}?" do
      self.status == status
    end
  end

  def get_transaction
    Transaction.where(item_type: 'AlipayOrder', item_id: self.id).first
  end

  def pay
    if pending?
      ActiveRecord::Base.transaction do
        self.user.income(credits, 'alipay_recharge', self)
        update_attributes(status: 'paid')
      end
    end
  end

  def save_alipay_trade_no(alipay_trade_no)
    update_attributes(alipay_trade_no: alipay_trade_no) unless self.alipay_trade_no
  end

  def save_trade_no_to_transaction(trade_no)
    @transaction = self.get_transaction
    @transaction.update_attributes(trade_no: trade_no)
  end
end
