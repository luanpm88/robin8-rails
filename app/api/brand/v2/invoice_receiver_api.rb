module Brand
  module V2
    class InvoiceReceiverAPI < Base
      before do
        authenticate!
      end
      resource :invoice_receiver do

        get "/" do
          @invoice_receiver = current_user.invoice_receiver
          if @invoice_receiver
            present @invoice_receiver, with: Entities::InvoiceReceiver
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
          @invoice_receiver = current_user.invoice_receiver
          if @invoice_receiver
            @invoice_receiver.update_attributes(declared(params))
          else
            @invoice_receiver = current_user.build_invoice_receiver(declared(params))
          end
          
          if @invoice_receiver.save
            present @invoice_receiver, with: Entities::InvoiceReceiver
          else
            return {error: 1, detail: I18n.t('brand_api.errors.messages.save_error')}
          end
        end

      end
    end
  end
end