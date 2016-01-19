class Withdraw < ActiveRecord::Base
  validates_presence_of :real_name, :credits
  validates_numericality_of :credits
  validates_presence_of :alipay_no, :if => Proc.new{|t| t.withdraw_type == 'alipay'}
  validates_presence_of :bank_name, :bank_no, :if => Proc.new{|t| t.withdraw_type == 'bank'}

  validate :check_avail_amount

  belongs_to :kol
  scope :pending, -> {where(:status => 'pending')}

  def check_avail_amount
    avail_amount = Kol.find(kol_id).avail_amount rescue 0
    if avail_amount.to_f < credits.to_f
      self.errors.add(:credits, "超出账户可用金额")
    end
  end
end
