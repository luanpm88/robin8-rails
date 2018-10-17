class EWallet::Transtion < ActiveRecord::Base
  
  STATUS = %w(pending successful failed)
  DIRECTS = %w(income)

  STATUS_HASH = {
    pending:    '待支付',
    successful: '支付成功',
    failed:     '支付失败'
  }

  belongs_to :resource, polymorphic: true
  belongs_to :kol

  validates_inclusion_of :status, in: STATUS
  validates_inclusion_of :direct, in: DIRECTS

  scope :pending,    -> {where(status: 'pending').order('created_at desc')}
  scope :successful, -> {where(status: 'successful').order('created_at desc')}
  scope :failed,     -> {where(status: 'failed').order('created_at desc')}
  scope :unpaid,     -> {where("status<>'successful'").order('created_at desc')}

  def pending?
  	self.status == "pending"
  end

  def title
    case resource_type
    when 'Campaign'
      "活动奖励：#{resource.name}"
    end
  end

  def to_hash
    {
      time: created_at.to_s(:db),
      title: title,
      amount: amount.to_f,
      status: STATUS_HASH[status.to_sym]
    }
  end

end
