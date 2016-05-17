class InvoiceHistory < ActiveRecord::Base

  validates :credits, :invoice_type, :title, :address, presence: true

  belongs_to :user
end
