module Brand
  module V2
    class InvoicesAPI < Base
      before do
        authenticate!
      end

      resource :invoices do
       
        get "special" do
          @invoice = current_user.special_invoice
          if @invoice
            present @invoice, with: Entities::Invoice
          else
            { no_invoice: true }
          end
        end

        params do
          requires :title, type: String
          optional :invoice_type, type: String, default: 'special'
          requires :taxpayer_id, type: String
          requires :company_address, type: String
          requires :company_mobile, type:String
          requires :bank_name, type:String
          requires :bank_account, type:String
          # optional :id, type: Integer
        end
        post "special" do
          @invoice = current_user.invoices.find_or_initialize_by(id: params[:id])

          if @invoice.new_record?
            @invoice = current_user.invoices.new(declared(params))
          else
             @invoice.update_attributes(declared(params))
          end
          if @invoice.save
            present @invoice, with: Entities::Invoice
          else
            return {error: 1, detail: I18n.t('brand_api.errors.messages.save_error')}
          end
        end

      end
    end
  end
end