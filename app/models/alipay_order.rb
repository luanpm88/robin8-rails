class AlipayOrder < ActiveRecord::Base
  STATUS = %w(pending paid)

  validates :trade_no, presence: true, uniqueness: true
  validates :credits, presence: true
  validates :credits, numericality: { greater_than_or_equal_to: 500 }

  validates_inclusion_of :status, :in => STATUS

  belongs_to :user
  after_create :update_user_status

  STATUS.each do |status|
    define_method "#{status}?" do
      self.status == status
    end
  end

  def update_user_status
    unless self.user.is_active
      self.user.update(:is_active => true)
    end
  end

  def get_transaction
    Rails.logger.alipay.info "-------- 进入pay_transaction方法  ---alipay_id:#{self.id} 获取 transaction --------------"
    Transaction.where(item_type: 'AlipayOrder', item_id: self.id).first
  end

  def pay
    if pending?
      Rails.logger.alipay.info "-------- 进入pay方法  ---alipay_id:#{self.id} --------------"
      self.user.income(credits, 'alipay_recharge', self)
      update_attributes!(status: 'paid')
      Rails.logger.alipay.info "--------  ---alipay_id:#{self.id} ---- 更改订单状态成功(支付成功)  --------------"
      increase_user_appliable_credits if need_invoice
    end
  end

  def save_alipay_trade_no(alipay_trade_no)
    Rails.logger.alipay.info "-------- 进入save_alipay_trade_no方法 保存支付宝订单号到alipay_order  ---alipay_id:#{self.id} ----alipay_trade_no: #{alipay_trade_no} --------------"
    update_attributes!(alipay_trade_no: alipay_trade_no) unless self.alipay_trade_no
  end

  def save_trade_no_to_transaction(trade_no)
    Rails.logger.alipay.info "-------- 进入save_trade_no_to_transaction方法 保存本站订单号到transaction  ---alipay_id:#{self.id} ----trade_no: #{trade_no} --------------"
    @transaction = self.get_transaction
    @transaction.update_attributes!(trade_no: trade_no)
  end

  def save_tax_to_transaction
    Rails.logger.alipay.info "-------- 进入save_tax_to_transaction方法 保存充值税费至transaction  ---alipay_id:#{self.id}  --------------"
    @transaction = self.get_transaction
    @transaction.update_attributes!(tax: tax)
  end

  def increase_user_appliable_credits
    Rails.logger.alipay.info "-------- 进入increase_user_appliable_credits方法 增加用户可提现金额  ---alipay_id:#{self.id}  --------------"
    @transaction = self.get_transaction
    Rails.logger.alipay.info "--------  ---alipay_id:#{self.id} ---- 成功获取到对应transaction  --------------"
    @transaction.account.increment!(:appliable_credits, (tax + credits))
    Rails.logger.alipay.info "--------  ---alipay_id:#{self.id} ---- 添加可提现金额成功  --------------"
  end
end
