class Withdraw < ActiveRecord::Base
  belongs_to :kol
  validates_presence_of :real_name, :credits
  validates_numericality_of :credits
  validates_presence_of :alipay_no, :if => Proc.new{|t| t.withdraw_type == 'alipay'}
  validates_presence_of :bank_name, :bank_no, :if => Proc.new{|t| t.withdraw_type == 'bank'}

  validate :check_avail_amount

  after_create :frozen_withdraw_amount
  after_save :deal_withdraw

  belongs_to :kol
  scope :whole, ->{order('created_at desc')}
  scope :pending, -> {where(:status => 'pending').order('created_at desc')}
  scope :approved, -> {where(:status => 'paid').order('created_at desc')}
  scope :rejected, -> {where(:status => 'rejected').order('created_at desc')}

  def check_avail_amount
    avail_amount = Kol.find(kol_id).avail_amount rescue 0
    if avail_amount.to_f < credits.to_f
      self.errors.add(:credits, "超出账户可用金额")
    end
  end

  def frozen_withdraw_amount
    self.kol.frozen(self.credits,'widthdraw', self, nil)
  end


  def deal_withdraw
    if self.status_changed? && self.status == 'paid'
      # 解冻并提现
      self.kol.unfrozen(self.credits,'widthdraw', self, nil)
      self.kol.payout(self.credits, 'withdraw',self,nil)
    elsif self.status_changed? && self.status == 'rejected'
      # 解冻
      self.kol.unfrozen(self.credits,'widthdraw', self, nil)
    end
  end
end
