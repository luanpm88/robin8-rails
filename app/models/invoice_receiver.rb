class InvoiceReceiver < ActiveRecord::Base
  validates :name, :phone_number, :address, presence: true

  belongs_to :user
end
