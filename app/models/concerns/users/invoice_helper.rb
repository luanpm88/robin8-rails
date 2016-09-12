module Users
  module InvoiceHelper
    extend ActiveSupport::Concern
    def common_invoice
      self.invoices.where(invoice_type: 'common').take
    end

    def special_invoice
      self.invoices.where(invoice_type: 'special').take
    end
  end
end
