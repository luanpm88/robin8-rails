module Brand
  module V2
    class InvoiceHistoriesAPI < Base
      include Grape::Kaminari
      before do
        authenticate!
      end

      resource :invoice_histories do
        
        get "/" do
          invoice_histories = paginate(Kaminari.paginate_array(current_user.invoice_histories.order('created_at DESC')))

          present invoice_histories, with: Entities::InvoiceHistory
        end

        desc '可申请发票的总额'
        get '/appliable_credits' do
          appliable_credits = current_user.appliable_credits
          { appliable_credits: appliable_credits }
        end

        
        params do
          requires :credits, type: String
          requires :type, type: String
          requires :price_sheet, type: Boolean
        end
        post '/' do
          if !current_user.special_invoice
            return {error: 1, detail: '请完善发票信息，然后重试'}
          elsif !current_user.invoice_receiver
            return {error: 1, detail: '请完善发票邮寄地址信息，然后重试'}
          elsif current_user.appliable_credits < params[:credits].to_i
            return {error: 1, detail: '输入金额超出可申请金额'}
          end

          invoice_history_params = current_user.special_invoice.slice(:title, :taxpayer_id, :company_address, :company_mobile, :bank_name, :bank_account).merge(
                                   current_user.invoice_receiver.slice(:name, :phone_number, :address).merge(
                                   { credits: params[:credits], invoice_type: params[:type], price_sheet: params[:price_sheet] } ))

          @invoice_history = current_user.invoice_histories.build(invoice_history_params)
          if @invoice_history.save
            current_user.decrement!(:appliable_credits, params[:credits].to_i)
            invoice_histories = paginate(Kaminari.paginate_array(current_user.invoice_histories.order('created_at DESC')))
            present invoice_histories
          else
            return {error: 1, detail: @invoice_history.errors.messages.first.last.first}
          end
        end

      end
    end
  end
end