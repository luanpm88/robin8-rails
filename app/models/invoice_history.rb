class InvoiceHistory < ActiveRecord::Base

  validates :credits, :invoice_type, :title, :address, presence: true
  validates :credits, numericality: { only_integer: true }
  validates :credits, numericality: { greater_than_or_equal_to: 500 }
  validates :tracking_number, allow_nil: true, uniqueness: true

  belongs_to :user

  def company_info
    [company_address, company_mobile].join(' ')
  end

  def bank_info
    [bank_name, bank_account].join(' ')
  end

  def status_zh
    case self.status
    when 'pending'
      '等待邮寄'
    when 'sent'
      '已经邮寄'
    else
      '等待邮寄'
    end
  end
end
