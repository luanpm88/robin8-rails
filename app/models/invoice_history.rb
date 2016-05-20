class InvoiceHistory < ActiveRecord::Base

  validates :credits, :invoice_type, :title, :address, presence: true
  validates :credits, numericality: { only_integer: true }
  validates :credits, numericality: { greater_than_or_equal_to: 500 }
  validates :tracking_number, allow_nil: true, uniqueness: true

  belongs_to :user
end
