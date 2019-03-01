module Brand
  module V2
    class InvoiceReceiverAPI < Base
      before do
        authenticate!
      end

      get "/" do
        @invoice_receiver = current_user.invoice_receiver
        if @invoice_receiver
          present @invoice_receiver
        else
          { no_invoice_receiver: true }
        end
      end

      params do
        requires :name, type: String
        requires :phone_number, type: String
        requires :address, type: String
      end
      post "/" do
        @invoice_receiver = current_user.build_invoice_receiver(declared(params))
        if @invoice_receiver.save
          present @invoice_receiver
        else
          error_unprocessable! "保存失败，请重试"
        end
      end

      params do
        requires :name, type: String
        requires :phone_number, type: String
        requires :address, type: String
      end
      put "/" do
        @invoice_receiver = current_user.invoice_receiver
        @invoice_receiver.update_attributes(declared(params))
        present @invoice_receiver
      end
    end
  end
end
