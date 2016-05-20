class InvoiceHistory < ActiveRecord::Base

  validates :credits, :invoice_type, :title, :address, presence: true
  validates :tracking_number, uniqueness: true
  
  belongs_to :user
end
