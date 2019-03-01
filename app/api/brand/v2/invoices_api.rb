module Brand
  module V2
    class InvoicesAPI < Base
      before do
        authenticate!
      end

      resource :invoices do
        get "common" do

          @invoice = current_user.common_invoice
          if @invoice
            present @invoice
          else
            { no_invoice: true }
          end
        end

        params do
          requires :title, type: String
        end
        post "common" do
          @invoice = current_user.invoices.new(declared(params))
          if @invoice.save
            present @invoice
          else
            error_unprocessable! "保存失败，请重试"
          end
        end

        params do
          requires :title, type: String
        end
        put "common" do
          @invoice = current_user.common_invoice
          @invoice.update_attributes(title: declared(params)[:title])
          present @invoice
        end

        get "special" do
          @invoice = current_user.special_invoice
          if @invoice
            present @invoice
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
        end
        post "special" do
          @invoice = current_user.invoices.new(declared(params))
          if @invoice.save
            present @invoice
          else
            error_unprocessable! "保存失败，请重试"
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
        end
        put "special" do
          @invoice = current_user.special_invoice
          @invoice.update_attributes(declared(params))
          present @invoice
        end
      end
    end
  end
end
