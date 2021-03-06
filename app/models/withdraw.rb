class Withdraw < ActiveRecord::Base
  
  belongs_to :kol
  belongs_to :user

  validates_presence_of :real_name, :credits, :if => Proc.new{|t| t.kol_id.present? }
  validates_numericality_of :credits
  validates_presence_of :alipay_no, :if => Proc.new{|t| t.withdraw_type == 'alipay'}

  validate :check_avail_amount, :on => :create

  after_create :frozen_withdraw_amount
  after_create :check_alipay_account
  after_save :deal_withdraw

  STATUS = %w(pending paid rejected checked permanent_frozen)

  scope :whole, ->{order('created_at desc')}
  scope :pending, -> {where(:status => 'pending').order('created_at desc')}
  scope :checked, -> { where(:status => 'checked').order('created_at desc') }
  scope :approved, -> {where(:status => 'paid').order('created_at desc')}
  scope :rejected, -> {where(:status => 'rejected').order('created_at desc')}
  scope :of_kols, -> { where.not(kol_id: nil) }

  def check_avail_amount
    return true if self.user_id.present?
    avail_amount = Kol.find(kol_id).avail_amount rescue 0
    if avail_amount.to_f < credits.to_f
      self.errors.add(:credits, "超出账户可用金额")
    end
  end

  def check_alipay_account
    return true if self.user_id.present?
    if AlipayAccountBlacklist.where(account: self.alipay_no).present?
      self.update_attributes(status: :rejected)
    end
  end

  def frozen_withdraw_amount
    return true if self.user_id.present?
    self.kol.frozen(self.credits,'withdraw', self, nil)
  end

  def deal_withdraw
    
    # Why does the withdraw model allow the payout if the user_id is present? Both user and kol model include the PayTransaction concern. 
    # So deal_withdraw can be called from both side. 
    # According to the previous design, if the method is called from the "user" model side, the payout will be initiated immediately. 
    # If the method is called from the "kol" side, the payout needs to evaluated.
     if self.user_id.present?
      self.user.payout(self.credits, 'withdraw',self,nil)
    else
      if self.kol.frozen_amount.to_f < self.credits.to_f
        self.errors.add(:credits, "超出账户冻结金额")
        return
      end
      if self.status_changed? && self.status == 'paid'
        # 解冻并提现
        self.kol.unfrozen(self.credits,'withdraw', self, nil)
        # Payout method is called through kol class, but it is implemented in the PayTransaction.rb concern
        self.kol.payout(self.credits, 'withdraw',self,nil)
        if self.kol.mobile_number.present?
          SmsMessage.send_by_resource_to(self.kol, "恭喜您！你在Robin8的提现已到账！速去支付宝[账单]中查看！", self)
        end
      elsif self.status_changed? && self.status == 'rejected'
        # 解冻
        if self.kol.mobile_number.present?
          SmsMessage.send_by_resource_to(self.kol, "您在Robin8的提现审核被拒绝，请去APP查看！(原因:#{self.reject_reason})", self)
        end
        self.kol.unfrozen(self.credits,'withdraw', self, nil)
      elsif self.status_changed? && self.status == 'confiscated'
      # 解冻后没收
        self.kol.confiscate(self.credits, 'confiscate',self,nil)
        # if self.kol.mobile_number.present?
        # #SmsMessage.send_by_resource_to(self.kol, "您在Robin8的提现被没收了:(，请去APP查看！(原因:#{self.reject_reason})", self)
        # end
        self.kol.unfrozen(self.credits,'withdraw', self, nil)
      end
    end
  end
end