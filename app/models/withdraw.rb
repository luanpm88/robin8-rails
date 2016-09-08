class Withdraw < ActiveRecord::Base
  belongs_to :kol
  validates_presence_of :real_name, :credits
  validates_numericality_of :credits
  validates_presence_of :alipay_no, :if => Proc.new{|t| t.withdraw_type == 'alipay'}
  validates_presence_of :bank_name, :bank_no, :if => Proc.new{|t| t.withdraw_type == 'bank'}

  validate :check_avail_amount, :on => :create

  after_create :frozen_withdraw_amount
  after_create :check_alipay_account
  after_save :deal_withdraw

  belongs_to :kol

  STATUS = %w(pending paid rejected checked permanent_frozen)

  scope :whole, ->{order('created_at desc')}
  scope :pending, -> {where(:status => 'pending').order('created_at desc')}
  scope :checked, -> { where(:status => 'checked').order('created_at desc') }
  scope :approved, -> {where(:status => 'paid').order('created_at desc')}
  scope :rejected, -> {where(:status => 'rejected').order('created_at desc')}

  def check_avail_amount
    avail_amount = Kol.find(kol_id).avail_amount rescue 0
    if avail_amount.to_f < credits.to_f
      self.errors.add(:credits, "超出账户可用金额")
    end
  end

  def check_alipay_account
    if AlipayAccountBlacklist.where(account: self.alipay_no).present?
      self.update_attributes(status: :rejected)
    end
  end

  def frozen_withdraw_amount
    self.kol.frozen(self.credits,'withdraw', self, nil)
  end

  def deal_withdraw
    if self.kol.frozen_amount.to_f < self.credits.to_f
      self.errors.add(:credits, "超出账户冻结金额")
      return
    end
    if self.status_changed? && self.status == 'paid'
      # 解冻并提现
        self.kol.unfrozen(self.credits,'withdraw', self, nil)
        self.kol.payout(self.credits, 'withdraw',self,nil)
        if self.kol.mobile_number.present?
          Emay::SendSms.to self.kol.mobile_number, "恭喜您！你在Robin8的提现已到账！速去支付宝查看！"
        end
    elsif self.status_changed? && self.status == 'rejected'
      # 解冻
      if self.kol.mobile_number.present?
        Emay::SendSms.to self.kol.mobile_number, "您在Robin8的提现审核被拒绝，请去APP查看！(原因:#{self.reject_reason})"
      end
      self.kol.unfrozen(self.credits,'withdraw', self, nil)
    end
  end
end
